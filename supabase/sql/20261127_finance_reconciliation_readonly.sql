-- FreeDom finance reconciliation diagnostics (READ ONLY)
-- Safe to run against production: SELECT statements only.
-- IMPORTANT: paid_amount is legacy operational state, not proof of collected cash.
-- Compare it with successful payment_allocations; do not auto-correct either side.

with allocation_totals as (
  select
    pa.booking_id, pa.order_id, pa.service_order_id, pa.event_registration_id,
    sum(pa.amount) filter (where p.status = 'успешно')::numeric as successful_allocated,
    sum(pa.amount) filter (where p.status = 'в обработке')::numeric as pending_allocated,
    sum(pa.amount) filter (where p.status = 'отменён')::numeric as cancelled_allocated,
    count(*) as allocation_count
  from public.payment_allocations pa
  join public.payments p on p.id = pa.payment_id
  group by pa.booking_id, pa.order_id, pa.service_order_id, pa.event_registration_id
),
charges as (
  select 'booking'::text as charge_type, b.id as charge_id, b.user_id,
         coalesce(b.total_amount,0)::numeric as gross_amount,
         coalesce(b.discount_amount,0)::numeric as discount_amount,
         coalesce(b.paid_amount,0)::numeric as legacy_paid_amount,
         coalesce(a.successful_allocated,0)::numeric as successful_allocated,
         coalesce(a.pending_allocated,0)::numeric as pending_allocated,
         coalesce(a.cancelled_allocated,0)::numeric as cancelled_allocated,
         coalesce(a.allocation_count,0) as allocation_count,
         b.status as charge_status, b.created_at
    from public.bookings b
    left join allocation_totals a on a.booking_id=b.id
  union all
  select 'order', o.id, o.user_id, coalesce(o.total_amount,0)::numeric,
         coalesce(o.discount_amount,0)::numeric, coalesce(o.paid_amount,0)::numeric,
         coalesce(a.successful_allocated,0)::numeric, coalesce(a.pending_allocated,0)::numeric,
         coalesce(a.cancelled_allocated,0)::numeric, coalesce(a.allocation_count,0),
         o.status, o.created_at
    from public.orders o
    left join allocation_totals a on a.order_id=o.id
  union all
  select 'service', so.id, so.user_id, coalesce(so.total_amount,0)::numeric,
         0::numeric, 0::numeric, coalesce(a.successful_allocated,0)::numeric,
         coalesce(a.pending_allocated,0)::numeric, coalesce(a.cancelled_allocated,0)::numeric,
         coalesce(a.allocation_count,0), so.status, so.created_at
    from public.service_orders so
    left join allocation_totals a on a.service_order_id=so.id
  union all
  select 'event', er.id, er.user_id, coalesce(er.amount,0)::numeric,
         0::numeric, coalesce(er.paid_amount,0)::numeric,
         coalesce(a.successful_allocated,0)::numeric, coalesce(a.pending_allocated,0)::numeric,
         coalesce(a.cancelled_allocated,0)::numeric, coalesce(a.allocation_count,0),
         er.status, er.created_at
    from public.event_registrations er
    left join allocation_totals a on a.event_registration_id=er.id
)
select charge_type, charge_id, user_id, charge_status, created_at,
       gross_amount, discount_amount,
       greatest(gross_amount-discount_amount,0) as net_charge,
       legacy_paid_amount, successful_allocated, pending_allocated, cancelled_allocated,
       allocation_count,
       (legacy_paid_amount-successful_allocated) as legacy_vs_ledger_delta,
       greatest(gross_amount-discount_amount-successful_allocated,0) as ledger_based_remaining
from charges
order by created_at desc, charge_type, charge_id;

-- Allocation integrity: exactly one target and a positive amount.
select pa.id, pa.payment_id, pa.amount,
       pa.booking_id, pa.order_id, pa.service_order_id, pa.event_registration_id,
       p.status as payment_status,
       ((pa.booking_id is not null)::int +
        (pa.order_id is not null)::int +
        (pa.service_order_id is not null)::int +
        (pa.event_registration_id is not null)::int) as target_count
from public.payment_allocations pa
join public.payments p on p.id=pa.payment_id
where pa.amount <= 0
   or ((pa.booking_id is not null)::int +
       (pa.order_id is not null)::int +
       (pa.service_order_id is not null)::int +
       (pa.event_registration_id is not null)::int) <> 1
order by p.created_at desc;

-- Successful payments without allocations (must be reviewed, not silently discarded).
select p.id, p.user_id, p.amount, p.payment_method, p.method, p.status, p.created_at
from public.payments p
where p.status='успешно'
  and not exists (
    select 1 from public.payment_allocations pa where pa.payment_id=p.id
  )
order by p.created_at desc;

-- RPC authorization inventory: identify SECURITY DEFINER functions whose body
-- contains the fixed owner email but does not explicitly fail closed on auth.uid().
select n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) as arguments,
       p.prosecdef,
       (p.prosrc ilike '%serzh.xz@mail.ru%') as uses_fixed_owner_email,
       (p.prosrc ilike '%auth.uid() is null%') as has_explicit_null_uid_guard,
       (p.prosrc ilike '%auth.email()%') as reads_auth_email
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.prosecdef
order by p.proname, arguments;
