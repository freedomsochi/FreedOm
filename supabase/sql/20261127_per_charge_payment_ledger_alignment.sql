-- FreeDom: align per-charge payment RPC with the successful-allocation ledger.
-- REVIEW/STAGING ARTIFACT ONLY. Do not apply to production without release approval.

begin;

create or replace function public.record_user_payment_for_charge(
  p_user_id uuid,
  p_charge_type text,
  p_charge_id uuid,
  p_amount integer,
  p_payment_method text default 'Перевод',
  p_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $function$
declare
  v_due integer;
  v_paid integer;
  v_total integer;
  v_discount integer;
  v_payment_id uuid;
  v_method text;
  v_status text;
begin
  if auth.uid() is null or auth.email() is distinct from 'serzh.xz@mail.ru' then
    raise exception 'Доступ запрещён' using errcode = '42501';
  end if;
  if p_user_id is null or p_charge_id is null or p_charge_type is null then
    raise exception 'Не указан пользователь или начисление';
  end if;
  if coalesce(p_amount, 0) <= 0 then
    raise exception 'Сумма оплаты должна быть больше нуля';
  end if;

  v_method := coalesce(nullif(trim(p_payment_method), ''), 'Перевод');

  if p_charge_type = 'booking' then
    select total_amount, coalesce(discount_amount, 0), coalesce(paid_amount, 0)
      into v_total, v_discount, v_paid
      from public.bookings
     where id = p_charge_id
       and user_id = p_user_id
       and coalesce(status, '') in ('подтверждено', 'confirmed', 'завершена')
     for update;
    if not found then raise exception 'Бронирование не найдено'; end if;
    v_due := greatest(coalesce(v_total, 0) - v_discount - v_paid, 0);

  elsif p_charge_type = 'order' then
    select total_amount, coalesce(discount_amount, 0), coalesce(paid_amount, 0)
      into v_total, v_discount, v_paid
      from public.orders
     where id = p_charge_id
       and user_id = p_user_id
       and coalesce(status, '') <> 'отменён'
     for update;
    if not found then raise exception 'Заказ кухни не найден'; end if;
    v_due := greatest(coalesce(v_total, 0) - v_discount - v_paid, 0);

  elsif p_charge_type = 'service' then
    select greatest(coalesce(so.total_amount, 0) - coalesce((
      select sum(pa.amount)
        from public.payment_allocations pa
        join public.payments p on p.id = pa.payment_id
       where pa.service_order_id = so.id
         and p.status = 'успешно'
    ), 0), 0)
      into v_due
      from public.service_orders so
     where so.id = p_charge_id
       and so.user_id = p_user_id
       and coalesce(so.status, '') not in ('отменён', 'отменена', 'cancelled')
     for update;
    if not found then raise exception 'Услуга не найдена'; end if;

  elsif p_charge_type = 'event' then
    select greatest(coalesce(er.amount, 0) - coalesce((
      select sum(pa.amount)
        from public.payment_allocations pa
        join public.payments p on p.id = pa.payment_id
       where pa.event_registration_id = er.id
         and p.status = 'успешно'
    ), 0), 0), coalesce(er.amount, 0)
      into v_due, v_total
      from public.event_registrations er
     where er.id = p_charge_id
       and er.user_id = p_user_id
       and coalesce(er.status, '') not in ('cancelled', 'отменена', 'отменено')
     for update;
    if not found then raise exception 'Регистрация на событие не найдена'; end if;
  else
    raise exception 'Неизвестный тип начисления';
  end if;

  if p_amount > v_due then
    raise exception 'Сумма оплаты (%) больше остатка по выбранному начислению (%)',
      p_amount, v_due;
  end if;

  insert into public.payments(
    user_id, amount, payment_method, method, note, created_by, status
  )
  values (
    p_user_id, p_amount, v_method, public.payment_method_code(v_method),
    p_note, auth.uid(), 'успешно'
  )
  returning id into v_payment_id;

  insert into public.payment_allocations(
    payment_id, booking_id, order_id, service_order_id, event_registration_id, amount
  )
  values (
    v_payment_id,
    case when p_charge_type = 'booking' then p_charge_id end,
    case when p_charge_type = 'order' then p_charge_id end,
    case when p_charge_type = 'service' then p_charge_id end,
    case when p_charge_type = 'event' then p_charge_id end,
    p_amount
  );

  if p_charge_type = 'booking' then
    v_paid := v_paid + p_amount;
    v_status := case
      when greatest(coalesce(v_total, 0) - v_discount - v_paid, 0) = 0 then 'оплачено'
      when v_paid > 0 then 'частично'
      else 'не оплачено'
    end;
    update public.bookings
       set paid_amount = v_paid, payment_status = v_status,
           payment_method = v_method, updated_at = now()
     where id = p_charge_id;

  elsif p_charge_type = 'order' then
    v_paid := v_paid + p_amount;
    v_status := case
      when greatest(coalesce(v_total, 0) - v_discount - v_paid, 0) = 0 then 'оплачено'
      when v_paid > 0 then 'частично'
      else 'не оплачено'
    end;
    update public.orders
       set paid_amount = v_paid, payment_status = v_status, updated_at = now()
     where id = p_charge_id;

  elsif p_charge_type = 'event' then
    select coalesce(sum(pa.amount), 0)::integer
      into v_paid
      from public.payment_allocations pa
      join public.payments p on p.id = pa.payment_id
     where pa.event_registration_id = p_charge_id
       and p.status = 'успешно';

    update public.event_registrations
       set paid_amount = coalesce(paid_amount, 0) + p_amount,
           payment_status = case
             when v_paid >= coalesce(amount, 0) then 'paid'
             when v_paid > 0 then 'partial'
             else coalesce(payment_status, 'unpaid')
           end,
           updated_at = now()
     where id = p_charge_id;
  end if;

  return jsonb_build_object(
    'ok', true,
    'payment_id', v_payment_id,
    'charge_type', p_charge_type,
    'charge_id', p_charge_id,
    'paid_amount', p_amount,
    'due_amount', v_due - p_amount
  );
end;
$function$;

commit;

-- Staging acceptance tests:
-- 1. Event due/status use successful allocations, not legacy paid_amount.
-- 2. Event/service concurrent calls serialize on the charge row.
-- 3. Booking/order preserve their current paid_amount opening balance.
-- 4. Null uid, anon, and non-owner authenticated calls fail closed.
-- 5. Payment allocations have exactly one target; amounts never exceed due.
-- 6. Existing function EXECUTE ACLs remain unchanged.
