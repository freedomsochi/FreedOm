-- READ ONLY verification for get_rooms_catalog hardening.
-- Run after the companion SQL patch in staging.

do $verify$
declare
  v_oid oid := to_regprocedure('public.get_rooms_catalog()');
  v_def text;
  v_result_columns text[];
begin
  if v_oid is null then
    raise exception 'get_rooms_catalog() is missing';
  end if;

  select pg_get_functiondef(v_oid) into v_def;

  if not (select prosecdef from pg_proc where oid=v_oid) then
    raise exception 'get_rooms_catalog() must bypass rooms RLS for the public catalog';
  end if;

  if v_def not ilike '%set search_path to ''pg_catalog''%' then
    raise exception 'Expected fixed pg_catalog search_path';
  end if;

  if v_def not ilike '%from public.rooms%' then
    raise exception 'Room source must be schema-qualified';
  end if;

  if has_function_privilege('anon',v_oid,'EXECUTE') is not true
     or has_function_privilege('authenticated',v_oid,'EXECUTE') is not true then
    raise exception 'Public catalog execute grants are missing';
  end if;

  if exists (
    select 1 from aclexplode(coalesce((select proacl from pg_proc where oid=v_oid),acldefault('f',(select proowner from pg_proc where oid=v_oid)))) a
    where a.grantee=0 and a.privilege_type='EXECUTE'
  ) then
    raise exception 'Implicit PUBLIC EXECUTE grant remains';
  end if;
end
$verify$;

select
  p.oid::regprocedure as function_signature,
  p.prosecdef as security_definer,
  p.proconfig as function_settings,
  has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
  has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute,
  exists(select 1 from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a where a.grantee=0 and a.privilege_type='EXECUTE') as public_execute
from pg_proc p
where p.oid=to_regprocedure('public.get_rooms_catalog()');

-- Staging smoke test: SELECT * FROM public.get_rooms_catalog() LIMIT 1;
-- Confirm the seven returned fields still match rooms-catalog.js.
