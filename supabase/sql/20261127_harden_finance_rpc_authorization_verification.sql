-- READ ONLY verification for finance RPC authorization hardening.
-- Run in staging after applying the companion SQL patch.

do $verify$
declare
  v_sig text;
  v_oid oid;
  v_def text;
  v_count integer := 0;
  v_public boolean;
begin
  foreach v_sig in array array[
    'public.add_service_order(uuid,uuid,integer,text)',
    'public.create_manual_guest(text,text,text,text,date,text)',
    'public.get_payment_history(uuid,uuid)',
    'public.get_user_payment_history(uuid)',
    'public.record_payment(uuid,uuid,integer,text,text)',
    'public.record_user_payment(uuid,integer,text,text)',
    'public.record_user_payment_for_charge(uuid,text,uuid,integer,text,text)',
    'public.record_event_registration_payment(uuid,integer,text)'
  ]
  loop
    v_oid := to_regprocedure(v_sig);
    if v_oid is null then
      raise exception 'Required finance RPC missing: %', v_sig;
    end if;

    select pg_get_functiondef(v_oid) into v_def;

    if (select proconfig from pg_proc where oid=v_oid) is distinct from array['search_path=pg_catalog']::text[] then
      raise exception 'Unsafe search_path in %', v_sig;
    end if;

    if has_function_privilege('anon',v_oid,'EXECUTE') then
      raise exception 'Anon can execute %', v_sig;
    end if;

    if not has_function_privilege('authenticated',v_oid,'EXECUTE') then
      raise exception 'Authenticated admin caller lost EXECUTE on %', v_sig;
    end if;

    select exists (
      select 1 from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a
      where a.grantee=0 and a.privilege_type='EXECUTE'
    ) into v_public
    from pg_proc p where p.oid=v_oid;

    if v_public then
      raise exception 'PUBLIC EXECUTE remains on %', v_sig;
    end if;

    if v_sig <> 'public.record_event_registration_payment(uuid,integer,text)' then
      if v_def not ilike '%auth.email() IS DISTINCT FROM ''serzh.xz@mail.ru''%' then
        raise exception 'NULL-safe administrator guard missing in %', v_sig;
      end if;
    else
      if v_def not ilike '%auth.email() IS DISTINCT FROM ''serzh.xz@mail.ru''%' then
        raise exception 'Administrator guard missing in event payment RPC';
      end if;
    end if;

    v_count := v_count + 1;
  end loop;

  if v_count <> 8 then
    raise exception 'Expected 8 verified functions, got %', v_count;
  end if;
end
$verify$;

select
  p.oid::regprocedure as signature,
  p.proconfig as function_settings,
  has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
  has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute,
  has_function_privilege('service_role',p.oid,'EXECUTE') as service_role_execute,
  exists(select 1 from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a where a.grantee=0 and a.privilege_type='EXECUTE') as public_execute
from pg_proc p
where p.oid in (
  to_regprocedure('public.add_service_order(uuid,uuid,integer,text)'),
  to_regprocedure('public.create_manual_guest(text,text,text,text,date,text)'),
  to_regprocedure('public.get_payment_history(uuid,uuid)'),
  to_regprocedure('public.get_user_payment_history(uuid)'),
  to_regprocedure('public.record_payment(uuid,uuid,integer,text,text)'),
  to_regprocedure('public.record_user_payment(uuid,integer,text,text)'),
  to_regprocedure('public.record_user_payment_for_charge(uuid,text,uuid,integer,text,text)'),
  to_regprocedure('public.record_event_registration_payment(uuid,integer,text)')
)
order by p.oid::regprocedure::text;
