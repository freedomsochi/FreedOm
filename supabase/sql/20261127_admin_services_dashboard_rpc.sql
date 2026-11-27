-- SOURCE-ONLY staging migration. Depends on private.has_admin_role().
begin;

do $preflight$
begin
  if to_regprocedure('private.has_admin_role()') is null then
    raise exception 'Missing prerequisite private.has_admin_role(); apply and validate admin-role-foundation.sql in staging first';
  end if;
  if exists (
    select 1 from pg_proc h
    where h.oid='private.has_admin_role()'::regprocedure
      and h.proowner <> (select oid from pg_roles where rolname=current_user)
  ) then
    raise exception 'Migration role must own the admin role helper';
  end if;
end
$preflight$;

create or replace function public.admin_get_services_dashboard()
returns jsonb
language plpgsql
stable
security definer
set search_path = pg_catalog
as $function$
declare
  v_result jsonb;
begin
  if auth.uid() is null or not private.has_admin_role() then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(to_jsonb(s) order by s.created_at desc), '[]'::jsonb)
    into v_result
  from (
    select so.id, so.user_id, so.service_name, so.unit, so.quantity,
           so.unit_price, so.total_amount, so.status, so.comment, so.created_at,
           coalesce((
             select sum(pa.amount)::integer
             from public.payment_allocations pa
             join public.payments p on p.id = pa.payment_id
             where pa.service_order_id = so.id
               and p.status = 'успешно'
           ), 0) as paid_amount
    from public.service_orders so
  ) s;

  return jsonb_build_object('services', v_result);
end
$function$;

revoke all on function public.admin_get_services_dashboard() from public, anon, authenticated;
grant execute on function public.admin_get_services_dashboard() to authenticated;

commit;
