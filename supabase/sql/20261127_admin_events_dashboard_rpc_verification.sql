-- READ ONLY verification for owner-only public.admin_get_events_dashboard().
-- Run after the companion migration in staging.

do $verify$
declare
  v_oid oid := to_regprocedure('public.admin_get_events_dashboard()');
  v_def text;
begin
  if v_oid is null then raise exception 'admin_get_events_dashboard() is missing'; end if;
  select pg_get_functiondef(v_oid) into v_def;

  if not (select prosecdef from pg_proc where oid=v_oid) then
    raise exception 'Events dashboard must be SECURITY DEFINER';
  end if;
  if not (select provolatile='s' from pg_proc where oid=v_oid) then
    raise exception 'Events dashboard must be STABLE';
  end if;
  if not (select proconfig @> array['search_path=pg_catalog'] from pg_proc where oid=v_oid) then
    raise exception 'Events dashboard search_path is not pinned';
  end if;
  if v_def not ilike '%auth.uid() is null%' or v_def not ilike '%private.has_owner_role()%' then
    raise exception 'Events dashboard must require authenticated owner role';
  end if;
  if pg_get_function_result(v_oid) <> 'jsonb'
     or v_def not ilike '%public.events%'
     or v_def not ilike '%public.event_registrations%' then
    raise exception 'Events dashboard result or data sources do not match contract';
  end if;
  if has_function_privilege('anon',v_oid,'EXECUTE')
     or not has_function_privilege('authenticated',v_oid,'EXECUTE')
     or has_function_privilege('service_role',v_oid,'EXECUTE') then
    raise exception 'Events dashboard EXECUTE grants are not owner-session only';
  end if;
  if exists(select 1 from aclexplode(coalesce((select proacl from pg_proc where oid=v_oid),acldefault('f',(select proowner from pg_proc where oid=v_oid)))) a
    where a.grantee=0 and a.privilege_type='EXECUTE') then
    raise exception 'Events dashboard still grants EXECUTE to PUBLIC';
  end if;
end
$verify$;

select p.oid::regprocedure as function_signature,
       pg_get_function_result(p.oid) as result_type,
       p.prosecdef as security_definer,
       p.provolatile='s' as stable,
       p.proconfig as function_settings,
       has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
       has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute,
       has_function_privilege('service_role',p.oid,'EXECUTE') as service_role_execute
from pg_proc p where p.oid=to_regprocedure('public.admin_get_events_dashboard()');
