-- READ ONLY verification for 20261127_harden_booking_and_payment_history_rpcs.sql.
-- Run immediately after that migration and before the final role migration.
-- Seven functions are expected; the later role migration replaces these
-- fail-closed email guards with private.has_admin_role()/has_owner_role().

do $verify$
declare
  v_count integer;
begin
  select count(*) into v_count
    from pg_proc p
    join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public'
     and p.oid in (
       to_regprocedure('public.admin_get_bookings()'),
       to_regprocedure('public.cancel_booking(uuid)'),
       to_regprocedure('public.confirm_booking(uuid)'),
       to_regprocedure('public.get_payment_history(uuid,uuid)'),
       to_regprocedure('public.get_user_payment_history(uuid)'),
       to_regprocedure('public.admin_get_kitchen_orders()'),
       to_regprocedure('public.admin_update_kitchen_order_status(uuid,text)')
     );
  if v_count <> 7 then
    raise exception 'Expected seven booking/payment/kitchen RPCs, found %',v_count;
  end if;

  if exists (
    select 1
      from pg_proc p
     where p.oid in (
       to_regprocedure('public.admin_get_bookings()'),
       to_regprocedure('public.cancel_booking(uuid)'),
       to_regprocedure('public.confirm_booking(uuid)'),
       to_regprocedure('public.get_payment_history(uuid,uuid)'),
       to_regprocedure('public.get_user_payment_history(uuid)'),
       to_regprocedure('public.admin_get_kitchen_orders()'),
       to_regprocedure('public.admin_update_kitchen_order_status(uuid,text)')
     )
       and (
         not p.prosecdef
         or not (p.proconfig @> array['search_path=pg_catalog'])
         or pg_get_functiondef(p.oid) not ilike '%auth.uid() is null or auth.email() is distinct from ''serzh.xz@mail.ru''%'
         or has_function_privilege('anon',p.oid,'EXECUTE')
         or not has_function_privilege('authenticated',p.oid,'EXECUTE')
         or has_function_privilege('service_role',p.oid,'EXECUTE') is false
         or exists (
           select 1 from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a
            where a.grantee=0 and a.privilege_type='EXECUTE'
         )
       )
  ) then
    raise exception 'One or more RPCs fail the expected guard/search_path/ACL checks';
  end if;
end
$verify$;

select
  p.oid::regprocedure as signature,
  pg_get_functiondef(p.oid) ilike '%auth.uid() is null or auth.email() is distinct from ''serzh.xz@mail.ru''%' as fail_closed_email_guard,
  p.proconfig @> array['search_path=pg_catalog'] as search_path_ok,
  has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_exec,
  has_function_privilege('anon',p.oid,'EXECUTE') as anon_exec,
  has_function_privilege('service_role',p.oid,'EXECUTE') as service_role_exec,
  exists (
    select 1 from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a
     where a.grantee=0 and a.privilege_type='EXECUTE'
  ) as public_exec
from pg_proc p
where p.oid in (
  to_regprocedure('public.admin_get_bookings()'),
  to_regprocedure('public.cancel_booking(uuid)'),
  to_regprocedure('public.confirm_booking(uuid)'),
  to_regprocedure('public.get_payment_history(uuid,uuid)'),
  to_regprocedure('public.get_user_payment_history(uuid)'),
  to_regprocedure('public.admin_get_kitchen_orders()'),
  to_regprocedure('public.admin_update_kitchen_order_status(uuid,text)')
)
order by 1;
