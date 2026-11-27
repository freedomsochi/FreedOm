-- READ ONLY verification for 20261127_harden_booking_and_payment_history_rpcs.sql.
-- Run after the booking/payment migration, either before or after the final role migration.
-- Seven functions are expected. Accept the intermediate fail-closed email guard
-- or the final admin/owner role guard installed by 20261127_admin_rpc_role_migration.sql.

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
         or not (
           pg_get_functiondef(p.oid) ilike '%auth.uid() is null or auth.email() is distinct from ''serzh.xz@mail.ru''%'
           or (
             case
               when p.proname in ('get_payment_history','get_user_payment_history')
                 then pg_get_functiondef(p.oid) ilike '%private.has_owner_role()%'
               else pg_get_functiondef(p.oid) ilike '%private.has_admin_role()%'
             end
           )
         )
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
  (
    pg_get_functiondef(p.oid) ilike '%auth.uid() is null or auth.email() is distinct from ''serzh.xz@mail.ru''%'
    or case
      when p.proname in ('get_payment_history','get_user_payment_history')
        then pg_get_functiondef(p.oid) ilike '%private.has_owner_role()%'
      else pg_get_functiondef(p.oid) ilike '%private.has_admin_role()%'
    end
  ) as authorization_guard_ok,
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
