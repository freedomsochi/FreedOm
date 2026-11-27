-- FreeDom account-linking security audit (READ ONLY)
-- This script returns trigger/function metadata and aggregate counts only.
-- It does not display guest contact details or modify records.

-- 1. Enumerate triggers that automatically attach bookings, orders, or event
--    registrations to an existing user based on submitted phone/email values.
select
  t.tgrelid::regclass as source_table,
  t.tgname as trigger_name,
  p.oid::regprocedure as trigger_function,
  pg_get_triggerdef(t.oid) as trigger_definition
from pg_trigger t
join pg_proc p on p.oid=t.tgfoid
where not t.tgisinternal
  and p.pronamespace='public'::regnamespace
  and (
    p.prosrc ilike '%find_user_by_phone%'
    or p.prosrc ilike '%guest_email%'
    or p.prosrc ilike '%guest_phone%'
    or p.prosrc ilike '%normalize_phone%'
  )
order by source_table,t.tgname;

-- 2. Count linked records whose supplied contact does not match a verified
--    contact on the linked Supabase Auth identity. These are review candidates,
--    not proof of account takeover: legacy records and profiles without Auth
--    phone/email confirmation can legitimately produce a mismatch.
select
  'bookings' as source_table,
  count(*) filter (where b.user_id is not null) as linked_records,
  count(*) filter (
    where b.user_id is not null
      and not (
        (u.phone_confirmed_at is not null
          and public.normalize_phone(u.phone) = public.normalize_phone(b.guest_phone))
        or
        (u.email_confirmed_at is not null
          and lower(trim(u.email)) = lower(trim(b.guest_email)))
      )
  ) as linked_contact_not_verified_match
from public.bookings b
join auth.users u on u.id=b.user_id

union all

select
  'orders',
  count(*) filter (where o.user_id is not null),
  count(*) filter (
    where o.user_id is not null
      and not (
        u.phone_confirmed_at is not null
        and public.normalize_phone(u.phone) = public.normalize_phone(o.guest_phone)
      )
  )
from public.orders o
join auth.users u on u.id=o.user_id

union all

select
  'event_registrations',
  count(*) filter (where e.user_id is not null),
  count(*) filter (
    where e.user_id is not null
      and not (
        u.phone_confirmed_at is not null
        and public.normalize_phone(u.phone) = public.normalize_phone(e.guest_phone)
      )
  )
from public.event_registrations e
join auth.users u on u.id=e.user_id;

-- 3. Review the exact linking function bodies before changing them.
select
  p.oid::regprocedure as function_signature,
  p.proconfig as function_config,
  p.prosrc as function_body
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.proname in (
    'find_user_by_phone',
    'attach_event_user_by_phone',
    'attach_user_by_phone',
    'link_booking_user_by_email',
    'attach_existing_event_registrations_to_user',
    'attach_existing_requests_to_user'
  )
order by p.proname;

-- Security design requirement:
-- A public guest form's phone/email is unverified input, not proof of account
-- ownership. Future linking should require the authenticated caller's own
-- verified Auth phone/email to match, or a separate OTP/verification flow.
-- Do not bulk unlink existing records: first reconcile legitimate historical
-- links with the business owner and preserve payment/booking history.
