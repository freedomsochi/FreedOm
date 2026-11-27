-- SOURCE-ONLY STAGING MIGRATION. Depends on private.has_admin_role().
-- Replaces browser reads from bookings, orders, service_orders, event_registrations,
-- payment_allocations and payments with one role-checked endpoint.
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

create or replace function public.admin_get_finance_charge_detail(
  p_charge_type text,
  p_charge_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = pg_catalog
as $function$
declare
  v_charge jsonb;
  v_allocations jsonb;
begin
  if auth.uid() is null or not private.has_admin_role() then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;
  if p_charge_id is null or p_charge_type is null or p_charge_type not in ('booking','order','service','event') then
    raise exception 'Invalid charge reference' using errcode = '22023';
  end if;

  if p_charge_type = 'booking' then
    select jsonb_build_object(
      'id', b.id, 'user_id', b.user_id, 'total_amount', b.total_amount,
      'discount_amount', b.discount_amount, 'paid_amount', b.paid_amount,
      'status', b.status, 'payment_status', b.payment_status,
      'check_in_date', b.check_in_date, 'check_out_date', b.check_out_date,
      'guest_count', b.guest_count, 'services', b.services, 'room_name', r.name
    ) into v_charge
    from public.bookings b left join public.rooms r on r.id=b.room_id
    where b.id=p_charge_id;
  elsif p_charge_type = 'order' then
    select jsonb_build_object(
      'id', o.id, 'user_id', o.user_id, 'total_amount', o.total_amount,
      'discount_amount', o.discount_amount, 'paid_amount', o.paid_amount,
      'status', o.status, 'payment_status', o.payment_status,
      'created_at', o.created_at, 'items', o.items,
      'guest_name', o.guest_name, 'guest_phone', o.guest_phone
    ) into v_charge
    from public.orders o where o.id=p_charge_id;
  elsif p_charge_type = 'service' then
    select jsonb_build_object(
      'id', so.id, 'user_id', so.user_id, 'service_name', so.service_name,
      'unit', so.unit, 'quantity', so.quantity, 'unit_price', so.unit_price,
      'total_amount', so.total_amount, 'status', so.status,
      'comment', so.comment, 'created_at', so.created_at
    ) into v_charge
    from public.service_orders so where so.id=p_charge_id;
  else
    select jsonb_build_object(
      'id', er.id, 'user_id', er.user_id, 'amount', er.amount,
      'paid_amount', er.paid_amount, 'status', er.status,
      'payment_status', er.payment_status, 'participants', er.participants,
      'comment', er.comment, 'created_at', er.created_at,
      'event_name', e.name, 'event_date', e.event_date,
      'start_time', e.start_time, 'location', e.location
    ) into v_charge
    from public.event_registrations er
    left join public.events e on e.id=er.event_id
    where er.id=p_charge_id;
  end if;

  if v_charge is null then
    return null;
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'payment_id', p.id, 'amount', pa.amount,
    'payment_method', p.payment_method, 'method', p.method,
    'note', p.note, 'created_at', p.created_at
  ) order by p.created_at, p.id), '[]'::jsonb)
  into v_allocations
  from public.payment_allocations pa
  join public.payments p on p.id=pa.payment_id
  where p.status='успешно'
    and (
      (p_charge_type='booking' and pa.booking_id=p_charge_id)
      or (p_charge_type='order' and pa.order_id=p_charge_id)
      or (p_charge_type='service' and pa.service_order_id=p_charge_id)
      or (p_charge_type='event' and pa.event_registration_id=p_charge_id)
    );

  return jsonb_build_object('charge',v_charge,'allocations',v_allocations);
end
$function$;

revoke all on function public.admin_get_finance_charge_detail(text,uuid) from public, anon, authenticated;
grant execute on function public.admin_get_finance_charge_detail(text,uuid) to authenticated;

commit;
