-- READ ONLY verification for create_event_registration hardening.
-- Run in staging after the companion SQL patch. No test rows are created here.
-- Confirms both the RPC and its BEFORE trigger have the hardened definitions.

do $verify$
declare
  v_def text;
  v_oid oid := to_regprocedure('public.create_event_registration(uuid,text,text,text,integer,text)');
  v_trigger_oid oid := to_regprocedure('public.attach_event_user_by_phone()');
begin
  if v_oid is null then
    raise exception 'create_event_registration(uuid,text,text,text,integer,text) is missing';
  end if;

  select pg_get_functiondef(v_oid) into v_def;

  if not (select prosecdef from pg_proc where oid=v_oid) then
    raise exception 'Registration RPC must remain SECURITY DEFINER';
  end if;
  if v_def not ilike '%set search_path to ''pg_catalog''%' then
    raise exception 'Expected fixed pg_catalog search_path';
  end if;
  if v_def ilike '%find_user_by_phone%' then
    raise exception 'Unsafe phone-based account lookup remains';
  end if;
  if v_def not ilike '%auth.uid()%' or v_def not ilike '%phone_confirmed_at%' then
    raise exception 'Verified Auth identity check is missing';
  end if;
  if v_def not ilike '%is_active = true%' or v_def not ilike '%show_on_home = true%' then
    raise exception 'Registration RPC no longer restricts registration to public active events';
  end if;
  if v_def not ilike '%v_participants > 30%' or v_def not ilike '%2147483647%' then
    raise exception 'Participant or integer-amount bounds are missing';
  end if;

  if v_trigger_oid is null then
    raise exception 'Event registration identity trigger function is missing';
  end if;
  if not (select prosecdef from pg_proc where oid=v_trigger_oid) then
    raise exception 'Event identity trigger function must remain SECURITY DEFINER';
  end if;
  if pg_get_functiondef(v_trigger_oid) not ilike '%set search_path to ''pg_catalog''%' then
    raise exception 'Event identity trigger search_path is not pinned';
  end if;
  if pg_get_functiondef(v_trigger_oid) ilike '%find_user_by_phone%' then
    raise exception 'Unsafe trigger phone-based account lookup remains';
  end if;
  if pg_get_functiondef(v_trigger_oid) not ilike '%phone_confirmed_at%' then
    raise exception 'Trigger verified-phone check is missing';
  end if;

  -- The trigger must actually be attached to event_registrations and enabled.
  if not exists (
    select 1
      from pg_trigger t
     where t.tgfoid=v_trigger_oid
       and t.tgrelid='public.event_registrations'::regclass
       and not t.tgisinternal
       and t.tgenabled in ('O','A')
  ) then
    raise exception 'No enabled non-internal event_registrations trigger uses attach_event_user_by_phone()';
  end if;

  if has_function_privilege('anon', v_oid, 'EXECUTE') is not true
     or has_function_privilege('authenticated', v_oid, 'EXECUTE') is not true then
    raise exception 'Public registration EXECUTE grants were not preserved';
  end if;
  if exists (
    select 1
      from aclexplode(coalesce((select proacl from pg_proc where oid=v_oid), acldefault('f',(select proowner from pg_proc where oid=v_oid)))) a
     where a.grantee = 0 and a.privilege_type = 'EXECUTE'
  ) then
    raise exception 'Implicit PUBLIC EXECUTE grant remains';
  end if;
end
$verify$;

select
  p.oid::regprocedure as function_signature,
  p.prosecdef as security_definer,
  p.proconfig as function_settings,
  has_function_privilege('anon', p.oid, 'EXECUTE') as anon_execute,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_execute,
  exists (
    select 1 from aclexplode(coalesce(p.proacl, acldefault('f',p.proowner))) a
     where a.grantee=0 and a.privilege_type='EXECUTE'
  ) as public_execute
from pg_proc p
where p.oid = to_regprocedure('public.create_event_registration(uuid,text,text,text,integer,text)');

select
  t.tgname,
  t.tgrelid::regclass as source_table,
  t.tgenabled,
  pg_get_triggerdef(t.oid) as trigger_definition
from pg_trigger t
where t.tgfoid=to_regprocedure('public.attach_event_user_by_phone()')
  and not t.tgisinternal;

-- Manual staging test matrix using disposable identities:
-- 1. anon + a phone belonging to an existing user -> registration.user_id is NULL.
-- 2. authenticated user with unverified phone -> registration.user_id is NULL.
-- 3. authenticated user with verified matching phone -> registration.user_id = auth.uid().
-- 4. authenticated user with verified phone A but submitted phone B -> user_id is NULL.
-- 5. service_role invocation without user JWT -> user_id is NULL.
-- 6. blank/oversized name, malformed phone, participants 0/31, oversized email/comment -> rejected.
-- 7. valid public registration still succeeds and returns the inserted row (legacy client expects data.id).
-- 8. existing registration rows remain unchanged.
