-- FreeDom SECURITY DEFINER RPC inventory (READ ONLY)
-- Snapshot query for review before role-based authorization migration.
-- Does not change schema, grants, functions, or application data.

-- 1. All public SECURITY DEFINER functions, callable roles, search_path,
--    and simple authorization indicators. These indicators are not a substitute
--    for reading each function body.
select
  p.oid::regprocedure as function_signature,
  p.provolatile as volatility,
  coalesce(array_to_string(p.proconfig, ', '), '(database default)') as function_config,
  has_function_privilege('anon', p.oid, 'EXECUTE') as anon_execute,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_execute,
  case
    when p.prosrc ilike '%has_admin_role%' then 'role_helper'
    when p.prosrc ilike '%auth.uid() is null%' then 'explicit_uid_null_guard'
    when p.prosrc ilike '%auth.email()%distinct from%' then 'null_safe_email_guard'
    when p.prosrc ilike '%coalesce(auth.jwt()%' then 'jwt_null_safe_guard'
    when p.prosrc ilike '%serzh.xz@mail.ru%' then 'fixed_owner_guard_review'
    when p.prosrc ilike '%auth.uid()%' then 'uid_reference_review'
    else 'no_obvious_auth_marker_review'
  end as body_auth_marker
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.prosecdef
order by p.proname, p.oid;

-- 2. Functions executable by anon. Public endpoints are intentional only after
--    reviewing their input validation, output fields, data exposure, and rate
--    limiting. In particular, do not revoke these seven indiscriminately.
select
  p.oid::regprocedure as function_signature,
  p.prosrc
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.prosecdef
  and has_function_privilege('anon', p.oid, 'EXECUTE')
order by p.proname, p.oid;

-- 3. Known high-risk payment RPC must contain a fail-closed authorization guard
--    before any write. Current live baseline was found to have no auth check.
select
  p.oid::regprocedure as function_signature,
  (p.prosrc ilike '%auth.uid()%') as references_auth_uid,
  (p.prosrc ilike '%auth.email()%') as references_auth_email,
  (p.prosrc ilike '%has_admin_role%') as references_role_helper,
  p.prosrc
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname = 'record_event_registration_payment';

-- 4. Trigger functions are not normally PostgREST RPC entry points, but must
--    still be reviewed for SECURITY DEFINER ownership, safe search_path,
--    and data-linking behavior (especially phone/email-based account matching).
select
  p.oid::regprocedure as function_signature,
  coalesce(array_to_string(p.proconfig, ', '), '(database default)') as function_config,
  p.prosrc
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.prosecdef
  and p.prorettype = 'trigger'::regtype
order by p.proname;

-- Review notes:
-- * SECURITY DEFINER + authenticated EXECUTE is not inherently a flaw, but each
--   privileged RPC must authorize internally and have a deliberate caller set.
-- * Public booking, event signup, room catalog, availability, and home events
--   are distinct public use cases; preserve their legitimate anonymous access.
-- * record_event_registration_payment currently has authenticated EXECUTE but
--   no internal auth guard in the live baseline. Apply the separately reviewed
--   event payment integrity migration only in staging after approval.
-- * Phone matching is not proof of account ownership. Never link a guest to an
--   existing account solely because an unverified public form supplied a phone.
