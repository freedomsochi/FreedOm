-- FreeDom finance: serialize user-level payment allocation.
-- REVIEW/STAGING ARTIFACT ONLY. Do not apply to production without release approval.
--
-- Fixes the race in record_user_payment(): previously it read aggregate debt
-- before locking charge rows, allowing concurrent calls to allocate the same
-- outstanding balance. All charge rows for one guest are now locked in a
-- deterministic table/id order before debt is recomputed.
--
-- Legacy paid_amount remains the opening-balance source for bookings/orders/
-- events. Services continue to use successful payment_allocations. This
-- migration intentionally does not reconcile or rewrite historical balances.

begin;

create or replace function public.record_user_payment(
  p_user_id uuid,
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
  v_total_debt integer;
  v_remaining integer;
  v_payment_id uuid;
  v_method text;
  v_alloc integer;
  v_new_paid integer;
  r record;
begin
  if auth.uid() is null or auth.email() is distinct from 'serzh.xz@mail.ru' then
    raise exception 'Доступ запрещён' using errcode = '42501';
  end if;

  if p_user_id is null then
    raise exception 'Не указан пользователь';
  end if;

  if coalesce(p_amount, 0) <= 0 then
    raise exception 'Сумма оплаты должна быть больше нуля';
  end if;

  if not exists (select 1 from public.users u where u.user_id = p_user_id) then
    raise exception 'Пользователь не найден';
  end if;

  -- Lock every eligible charge before calculating the debt.
  -- A fixed table order and stable id order prevent cross-call lock inversion.
  perform b.id
    from public.bookings b
   where b.user_id = p_user_id
     and coalesce(b.status, '') in ('подтверждено', 'confirmed', 'завершена')
   order by b.id
   for update;

  perform o.id
    from public.orders o
   where o.user_id = p_user_id
     and coalesce(o.status, '') <> 'отменён'
   order by o.id
   for update;

  perform so.id
    from public.service_orders so
   where so.user_id = p_user_id
     and coalesce(so.status, '') not in ('отменён', 'отменена', 'cancelled')
   order by so.id
   for update;

  perform er.id
    from public.event_registrations er
   where er.user_id = p_user_id
     and coalesce(er.status, '') not in ('отменено', 'отменена', 'cancelled')
   order by er.id
   for update;

  -- Recompute debt only after all eligible charge rows are locked.
  select coalesce(sum(q.due), 0)::integer
    into v_total_debt
    from (
      select greatest(
        coalesce(b.total_amount, 0)
        - coalesce(b.discount_amount, 0)
        - coalesce(b.paid_amount, 0), 0
      ) as due
        from public.bookings b
       where b.user_id = p_user_id
         and coalesce(b.status, '') in ('подтверждено', 'confirmed', 'завершена')
      union all
      select greatest(
        coalesce(o.total_amount, 0)
        - coalesce(o.discount_amount, 0)
        - coalesce(o.paid_amount, 0), 0
      )
        from public.orders o
       where o.user_id = p_user_id
         and coalesce(o.status, '') <> 'отменён'
      union all
      select greatest(
        coalesce(so.total_amount, 0)
        - coalesce((
            select sum(pa.amount)
              from public.payment_allocations pa
              join public.payments p on p.id = pa.payment_id
             where pa.service_order_id = so.id
               and p.status = 'успешно'
          ), 0), 0
      )
        from public.service_orders so
       where so.user_id = p_user_id
         and coalesce(so.status, '') not in ('отменён', 'отменена', 'cancelled')
      union all
      select greatest(
        coalesce(er.amount, 0) - coalesce((
          select sum(pa.amount)
            from public.payment_allocations pa
            join public.payments p on p.id = pa.payment_id
           where pa.event_registration_id = er.id
             and p.status = 'успешно'
        ), 0), 0
      )
        from public.event_registrations er
       where er.user_id = p_user_id
         and coalesce(er.status, '') not in ('отменено', 'отменена', 'cancelled')
    ) q;

  if p_amount > v_total_debt then
    raise exception 'Сумма оплаты (%) больше текущего долга (%)',
      p_amount, v_total_debt;
  end if;

  v_remaining := p_amount;
  v_method := coalesce(nullif(trim(p_payment_method), ''), 'Перевод');

  insert into public.payments(
    user_id, amount, payment_method, method, note, created_by, status
  )
  values (
    p_user_id, p_amount, v_method,
    public.payment_method_code(v_method), p_note, auth.uid(), 'успешно'
  )
  returning id into v_payment_id;

  -- The same due calculation is used for allocation after the lock phase.
  for r in
    select q.charge_type, q.charge_id, q.due, q.created_at
      from (
        select 'booking'::text as charge_type, b.id as charge_id,
          greatest(coalesce(b.total_amount, 0)
            - coalesce(b.discount_amount, 0)
            - coalesce(b.paid_amount, 0), 0) as due,
          b.created_at
          from public.bookings b
         where b.user_id = p_user_id
           and coalesce(b.status, '') in ('подтверждено', 'confirmed', 'завершена')
        union all
        select 'order', o.id,
          greatest(coalesce(o.total_amount, 0)
            - coalesce(o.discount_amount, 0)
            - coalesce(o.paid_amount, 0), 0),
          o.created_at
          from public.orders o
         where o.user_id = p_user_id
           and coalesce(o.status, '') <> 'отменён'
        union all
        select 'service', so.id,
          greatest(coalesce(so.total_amount, 0) - coalesce((
            select sum(pa.amount)
              from public.payment_allocations pa
              join public.payments p on p.id = pa.payment_id
             where pa.service_order_id = so.id
               and p.status = 'успешно'
          ), 0), 0),
          so.created_at
          from public.service_orders so
         where so.user_id = p_user_id
           and coalesce(so.status, '') not in ('отменён', 'отменена', 'cancelled')
        union all
        select 'event', er.id,
          greatest(coalesce(er.amount, 0) - coalesce((
            select sum(pa.amount)
              from public.payment_allocations pa
              join public.payments p on p.id = pa.payment_id
             where pa.event_registration_id = er.id
               and p.status = 'успешно'
          ), 0), 0),
          er.created_at
          from public.event_registrations er
         where er.user_id = p_user_id
           and coalesce(er.status, '') not in ('отменено', 'отменена', 'cancelled')
      ) q
     where q.due > 0
     order by q.created_at, q.charge_type, q.charge_id
  loop
    exit when v_remaining <= 0;
    v_alloc := least(v_remaining, r.due);

    insert into public.payment_allocations(
      payment_id, booking_id, order_id, service_order_id,
      event_registration_id, amount
    )
    values (
      v_payment_id,
      case when r.charge_type = 'booking' then r.charge_id end,
      case when r.charge_type = 'order' then r.charge_id end,
      case when r.charge_type = 'service' then r.charge_id end,
      case when r.charge_type = 'event' then r.charge_id end,
      v_alloc
    );

    if r.charge_type = 'booking' then
      update public.bookings
         set paid_amount = coalesce(paid_amount, 0) + v_alloc,
             payment_status = case
               when greatest(coalesce(total_amount, 0)
                 - coalesce(discount_amount, 0)
                 - (coalesce(paid_amount, 0) + v_alloc), 0) = 0
                 then 'оплачено'
               when coalesce(paid_amount, 0) + v_alloc > 0
                 then 'частично'
               else 'не оплачено'
             end,
             payment_method = v_method,
             updated_at = now()
       where id = r.charge_id;

    elsif r.charge_type = 'order' then
      update public.orders
         set paid_amount = coalesce(paid_amount, 0) + v_alloc,
             payment_status = case
               when greatest(coalesce(total_amount, 0)
                 - coalesce(discount_amount, 0)
                 - (coalesce(paid_amount, 0) + v_alloc), 0) = 0
                 then 'оплачено'
               when coalesce(paid_amount, 0) + v_alloc > 0
                 then 'частично'
               else 'не оплачено'
             end,
             updated_at = now()
       where id = r.charge_id;

    elsif r.charge_type = 'event' then
      update public.event_registrations
         set paid_amount = coalesce(paid_amount, 0) + v_alloc,
             payment_status = case
               when coalesce(paid_amount, 0) + v_alloc >= coalesce(amount, 0)
                 then 'paid'
               when coalesce(paid_amount, 0) + v_alloc > 0
                 then 'partial'
               else coalesce(payment_status, 'unpaid')
             end,
             updated_at = now()
       where id = r.charge_id;
    end if;

    v_remaining := v_remaining - v_alloc;
  end loop;

  if v_remaining > 0 then
    raise exception 'Не удалось распределить оплату по задолженностям';
  end if;

  return jsonb_build_object(
    'ok', true,
    'payment_id', v_payment_id,
    'paid_amount', p_amount,
    'due_amount', v_total_debt - p_amount
  );
end;
$function$;

commit;

-- Staging acceptance tests (run in an isolated database with fixtures):
-- A. Two concurrent calls for one guest cannot allocate more than the debt.
-- B. A second call waits for the first call's row locks, then recomputes debt.
-- C. Allocation total equals payment amount and exactly one target is set.
-- D. Booking/order/event paid_amount and payment_status remain synchronized.
-- E. Service debt is reduced only by successful allocations.
-- F. Anon, missing uid, and non-owner auth are denied with SQLSTATE 42501.
-- G. Existing EXECUTE ACLs are inspected and preserved; no production rows
--    are backfilled, reconciled, or rewritten by this migration.
