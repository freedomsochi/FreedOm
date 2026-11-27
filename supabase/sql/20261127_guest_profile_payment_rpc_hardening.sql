-- FreeDom: harden the guest-profile payment RPC.
-- REVIEW/STAGING ARTIFACT ONLY. Do not apply to production without release approval.
--
-- The guest profile sends cash/card/transfer. The payments.method column is
-- constrained to нал/безнал/бонусы, so normalize via payment_method_code().
-- Lock the selected charge before calculating its current due amount, and
-- derive event paid status from successful ledger allocations.

begin;

create or replace function public.admin_record_guest_payment(
  p_user_id uuid,
  p_amount integer,
  p_method text,
  p_charge_type text default null,
  p_charge_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $function$
declare
  v_admin uuid;
  v_due integer;
  v_total integer;
  v_discount integer;
  v_paid integer;
  v_payment_id uuid;
  v_method_label text;
  v_method_code text;
  v_status text;
begin
  v_admin := auth.uid();
  if v_admin is null or auth.email() is distinct from 'serzh.xz@mail.ru' then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  if p_user_id is null or p_charge_id is null then
    raise exception 'user and charge are required';
  end if;
  if coalesce(p_amount, 0) <= 0 then
    raise exception 'invalid amount';
  end if;
  if lower(trim(coalesce(p_method, ''))) not in
     ('cash', 'card', 'transfer', 'наличные', 'нал', 'карта', 'перевод', 'безнал', 'бонусы') then
    raise exception 'invalid payment method';
  end if;
  if p_charge_type not in ('booking', 'order', 'event', 'service') then
    raise exception 'invalid charge type';
  end if;

  v_method_label := case lower(trim(p_method))
    when 'cash' then 'Наличные'
    when 'нал' then 'Наличные'
    when 'наличные' then 'Наличные'
    when 'card' then 'Карта'
    when 'transfer' then 'Перевод'
    when 'перевод' then 'Перевод'
    when 'безнал' then 'Безналичный расчёт'
    when 'бонусы' then 'Бонусы'
    else p_method
  end;
  v_method_code := public.payment_method_code(v_method_label);

  if p_charge_type = 'booking' then
    select greatest(
      coalesce(b.total_amount, 0) - coalesce(b.discount_amount, 0), 0
    ), coalesce(b.paid_amount, 0),
       coalesce(b.discount_amount, 0)
      into v_total, v_paid, v_discount
      from public.bookings b
     where b.id = p_charge_id
       and b.user_id = p_user_id
       and coalesce(b.status, '') in ('подтверждено', 'confirmed', 'завершена')
     for update;
    if not found then raise exception 'booking not found or not payable'; end if;
    v_due := greatest(v_total - v_paid, 0);

  elsif p_charge_type = 'order' then
    select greatest(
      coalesce(o.total_amount, 0) - coalesce(o.discount_amount, 0), 0
    ), coalesce(o.paid_amount, 0),
       coalesce(o.discount_amount, 0)
      into v_total, v_paid, v_discount
      from public.orders o
     where o.id = p_charge_id
       and o.user_id = p_user_id
       and coalesce(o.status, '') <> 'отменён'
     for update;
    if not found then raise exception 'order not found or not payable'; end if;
    v_due := greatest(v_total - v_paid, 0);

  elsif p_charge_type = 'service' then
    select greatest(coalesce(so.total_amount, 0), 0)
      into v_total
      from public.service_orders so
     where so.id = p_charge_id
       and so.user_id = p_user_id
       and coalesce(so.status, '') not in ('отменён', 'отменена', 'cancelled')
     for update;
    if not found then raise exception 'service not found or not payable'; end if;

    select coalesce(sum(pa.amount), 0)::integer
      into v_paid
      from public.payment_allocations pa
      join public.payments p on p.id = pa.payment_id
     where pa.service_order_id = p_charge_id
       and p.status = 'успешно';
    v_due := greatest(v_total - v_paid, 0);

  else
    select greatest(coalesce(er.amount, 0), 0)
      into v_total
      from public.event_registrations er
     where er.id = p_charge_id
       and er.user_id = p_user_id
       and coalesce(er.status, '') not in ('cancelled', 'отменена', 'отменено')
     for update;
    if not found then raise exception 'event registration not found or not payable'; end if;

    select coalesce(sum(pa.amount), 0)::integer
      into v_paid
      from public.payment_allocations pa
      join public.payments p on p.id = pa.payment_id
     where pa.event_registration_id = p_charge_id
       and p.status = 'успешно';
    v_due := greatest(v_total - v_paid, 0);
  end if;

  if v_due <= 0 then raise exception 'selected charge is already paid'; end if;
  if p_amount > v_due then
    raise exception 'amount exceeds selected charge debt';
  end if;

  insert into public.payments(
    user_id, amount, method, payment_method, status, created_by, note
  )
  values (
    p_user_id, p_amount, v_method_code, v_method_label,
    'успешно', v_admin,
    'allocated:' || p_charge_type || ':' || p_charge_id::text
  )
  returning id into v_payment_id;

  insert into public.payment_allocations(
    payment_id, amount, booking_id, order_id, service_order_id, event_registration_id
  )
  values (
    v_payment_id, p_amount,
    case when p_charge_type = 'booking' then p_charge_id end,
    case when p_charge_type = 'order' then p_charge_id end,
    case when p_charge_type = 'service' then p_charge_id end,
    case when p_charge_type = 'event' then p_charge_id end
  );

  if p_charge_type = 'booking' then
    update public.bookings
       set paid_amount = coalesce(paid_amount, 0) + p_amount,
           payment_status = case
             when greatest(coalesce(total_amount, 0)
               - coalesce(discount_amount, 0)
               - (coalesce(paid_amount, 0) + p_amount), 0) = 0
               then 'оплачено'
             else 'частично'
           end,
           payment_method = v_method_label,
           updated_at = now()
     where id = p_charge_id;

  elsif p_charge_type = 'order' then
    update public.orders
       set paid_amount = coalesce(paid_amount, 0) + p_amount,
           payment_status = case
             when greatest(coalesce(total_amount, 0)
               - coalesce(discount_amount, 0)
               - (coalesce(paid_amount, 0) + p_amount), 0) = 0
               then 'оплачено'
             else 'частично'
           end,
           updated_at = now()
     where id = p_charge_id;

  elsif p_charge_type = 'event' then
    update public.event_registrations
       set paid_amount = coalesce(paid_amount, 0) + p_amount,
           payment_status = case
             when v_paid + p_amount >= v_total then 'paid'
             when v_paid + p_amount > 0 then 'partial'
             else coalesce(payment_status, 'unpaid')
           end,
           updated_at = now()
     where id = p_charge_id;
  end if;

  return jsonb_build_object(
    'ok', true,
    'payment_id', v_payment_id,
    'amount', p_amount,
    'charge_type', p_charge_type,
    'charge_id', p_charge_id,
    'charge_remaining_debt', v_due - p_amount
  );
end;
$function$;

commit;

-- Staging acceptance tests (isolated fixtures only):
-- 1. cash/card/transfer are stored as нал/безнал/безнал in payments.method.
-- 2. Payment display labels remain human-readable in payments.payment_method.
-- 3. Anon, missing uid, and non-owner authenticated users are denied.
-- 4. A second concurrent payment waits on the charge row and rechecks debt.
-- 5. Booking/order payment_status and paid_amount match the new allocation.
-- 6. Service/event debt is computed from successful allocations only.
-- 7. Every allocation has exactly one target and amount equals payment amount.
-- 8. Existing EXECUTE ACLs are inspected and preserved; no production data changes.
