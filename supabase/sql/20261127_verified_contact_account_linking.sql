-- FreeDom: require verified Auth contacts for automatic guest/account linking.
-- STAGING / REVIEW ONLY. Do not apply to production without release approval.
--
-- Security rule:
-- A phone/email typed into a public guest form is untrusted input. A record may
-- be linked automatically only when the current authenticated Auth identity owns
-- that verified contact. Anonymous/service-role calls do not auto-link.
--
-- Existing user_id values are intentionally untouched. Historical links require
-- a separate business reconciliation; this migration is not a bulk unlink.

begin;

create or replace function public.attach_user_by_phone()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $function$
declare
  v_uid uuid := auth.uid();
  v_verified_phone text;
  v_guest_phone text;
begin
  if new.user_id is not null or v_uid is null then
    return new;
  end if;

  if tg_table_name not in ('bookings', 'orders') then
    return new;
  end if;

  v_guest_phone := case
    when tg_table_name = 'bookings' then new.guest_phone
    when tg_table_name = 'orders' then new.guest_phone
    else null
  end;

  select u.phone
    into v_verified_phone
    from auth.users u
   where u.id = v_uid
     and u.phone_confirmed_at is not null;

  if v_verified_phone is not null
     and public.normalize_phone(v_verified_phone) is not null
     and public.normalize_phone(v_verified_phone) = public.normalize_phone(v_guest_phone) then
    new.user_id := v_uid;
  end if;

  return new;
end;
$function$;

create or replace function public.attach_event_user_by_phone()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $function$
declare
  v_uid uuid := auth.uid();
  v_verified_phone text;
begin
  if new.user_id is not null or v_uid is null then
    return new;
  end if;

  select u.phone
    into v_verified_phone
    from auth.users u
   where u.id = v_uid
     and u.phone_confirmed_at is not null;

  if v_verified_phone is not null
     and public.normalize_phone(v_verified_phone) is not null
     and public.normalize_phone(v_verified_phone) = public.normalize_phone(new.guest_phone) then
    new.user_id := v_uid;
  end if;

  return new;
end;
$function$;

create or replace function public.link_booking_user_by_email()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $function$
declare
  v_uid uuid := auth.uid();
  v_verified_email text;
begin
  if new.user_id is not null or v_uid is null then
    return new;
  end if;

  select u.email
    into v_verified_email
    from auth.users u
   where u.id = v_uid
     and u.email_confirmed_at is not null;

  if v_verified_email is not null
     and lower(trim(v_verified_email)) = lower(trim(coalesce(new.guest_email, ''))) then
    new.user_id := v_uid;
  end if;

  return new;
end;
$function$;

create or replace function public.attach_existing_requests_to_user()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $function$
declare
  v_uid uuid := auth.uid();
  v_verified_phone text;
begin
  if v_uid is null or new.user_id is distinct from v_uid
     or new."Phone" is null or btrim(new."Phone") = '' then
    return new;
  end if;

  select u.phone
    into v_verified_phone
    from auth.users u
   where u.id = v_uid
     and u.phone_confirmed_at is not null;

  if v_verified_phone is null
     or public.normalize_phone(v_verified_phone) is distinct from public.normalize_phone(new."Phone") then
    return new;
  end if;

  update public.bookings
     set user_id = v_uid
   where user_id is null
     and public.normalize_phone(guest_phone) = public.normalize_phone(v_verified_phone);

  update public.orders
     set user_id = v_uid
   where user_id is null
     and public.normalize_phone(guest_phone) = public.normalize_phone(v_verified_phone);

  return new;
end;
$function$;

create or replace function public.attach_existing_event_registrations_to_user()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $function$
declare
  v_uid uuid := auth.uid();
  v_verified_phone text;
begin
  if v_uid is null or new.user_id is distinct from v_uid
     or new."Phone" is null or btrim(new."Phone") = '' then
    return new;
  end if;

  select u.phone
    into v_verified_phone
    from auth.users u
   where u.id = v_uid
     and u.phone_confirmed_at is not null;

  if v_verified_phone is null
     or public.normalize_phone(v_verified_phone) is distinct from public.normalize_phone(new."Phone") then
    return new;
  end if;

  update public.event_registrations
     set user_id = v_uid
   where user_id is null
     and public.normalize_phone(guest_phone) = public.normalize_phone(v_verified_phone);

  return new;
end;
$function$;

-- These are trigger-only functions, not client-callable RPC endpoints.
revoke all on function public.attach_user_by_phone() from public, anon, authenticated;
revoke all on function public.attach_event_user_by_phone() from public, anon, authenticated;
revoke all on function public.link_booking_user_by_email() from public, anon, authenticated;
revoke all on function public.attach_existing_requests_to_user() from public, anon, authenticated;
revoke all on function public.attach_existing_event_registrations_to_user() from public, anon, authenticated;

commit;

-- Staging verification:
-- 1. Anonymous guest booking/order/event signup remains possible but user_id stays null.
-- 2. Authenticated user with unverified phone/email does not get automatic linking.
-- 3. Authenticated user with verified matching phone links only to auth.uid().
-- 4. Verified email links a booking only to auth.uid(), never to a profile selected
--    by matching arbitrary public input.
-- 5. Updating a public.users phone without matching verified Auth phone links nothing.
-- 6. Existing user_id values and payment/booking history remain unchanged.
-- 7. Verify all five trigger definitions and that trigger execution still works
--    after client EXECUTE is revoked from the trigger-only functions.
--
-- Rollback: restore the exact pre-migration definitions captured in the audit
-- commit before applying this migration. Do not attempt a generic inverse rewrite.
