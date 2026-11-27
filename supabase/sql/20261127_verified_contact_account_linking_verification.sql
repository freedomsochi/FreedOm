-- Verified-contact account-linking migration verification (READ ONLY)
-- Run in staging after 20261127_verified_contact_account_linking.sql.
-- No writes, no impersonation, no exposure of contact values.

do $verify$
declare
  v_name text;
  v_def text;
  v_required text[] := array[
    'attach_user_by_phone()',
    'attach_event_user_by_phone()',
    'link_booking_user_by_email()',
    'attach_existing_requests_to_user()',
    'attach_existing_event_registrations_to_user()'
  ];
begin
  foreach v_name in array v_required loop
    select pg_get_functiondef(to_regprocedure('public.' || v_name))
      into v_def;

    if v_def is null then
      raise exception 'Missing trigger function: %', v_name;
    end if;

    if v_def not ilike '%set search_path to ''pg_catalog''%' then
      raise exception 'Unsafe/unexpected search_path on %', v_name;
    end if;

    if v_def not ilike '%auth.uid()%' then
      raise exception 'Authenticated identity check missing on %', v_name;
    end if;
  end loop;

  if (select count(*)
        from pg_proc p
        join pg_namespace n on n.oid=p.pronamespace
       where n.nspname='public'
         and p.proname in (
           'attach_user_by_phone',
           'attach_event_user_by_phone',
           'link_booking_user_by_email',
           'attach_existing_requests_to_user',
           'attach_existing_event_registrations_to_user'
         )
         and p.prosecdef) <> 5 then
    raise exception 'Expected all five linking trigger functions to remain SECURITY DEFINER';
  end if;

  if exists (
    select 1
      from pg_proc p
      join pg_namespace n on n.oid=p.pronamespace
     where n.nspname='public'
       and p.proname in (
         'attach_user_by_phone',
         'attach_event_user_by_phone',
         'link_booking_user_by_email',
         'attach_existing_requests_to_user',
         'attach_existing_event_registrations_to_user'
       )
       and (
         has_function_privilege('anon',p.oid,'EXECUTE')
         or has_function_privilege('authenticated',p.oid,'EXECUTE')
         or has_function_privilege('public',p.oid,'EXECUTE')
       )
  ) then
    raise exception 'A trigger-only linking function is still directly executable by client roles/PUBLIC';
  end if;
end
$verify$;

-- Confirm trigger attachment points remain intact.
select
  t.tgrelid::regclass as source_table,
  t.tgname,
  p.oid::regprocedure as trigger_function,
  pg_get_triggerdef(t.oid) as trigger_definition
from pg_trigger t
join pg_proc p on p.oid=t.tgfoid
where not t.tgisinternal
  and p.pronamespace='public'::regnamespace
  and p.proname in (
    'attach_user_by_phone',
    'attach_event_user_by_phone',
    'link_booking_user_by_email',
    'attach_existing_requests_to_user',
    'attach_existing_event_registrations_to_user'
  )
order by source_table,t.tgname;

-- Manual staging matrix with disposable identities and fixtures:
-- A. anon + arbitrary guest phone/email: insert succeeds; user_id remains null.
-- B. authenticated user, unverified phone/email: no auto-link.
-- C. authenticated user, verified matching phone: only auth.uid() is assigned.
-- D. authenticated user, verified email: booking links only to auth.uid().
-- E. user profile phone changed to another person's number: no historical links.
-- F. service-role booking creation without user JWT: no auto-link.
-- G. verify existing linked rows are unchanged and payment history remains intact.
