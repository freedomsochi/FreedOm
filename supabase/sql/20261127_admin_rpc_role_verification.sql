-- FreeDom role-based admin RPC verification (READ ONLY)
-- Run only after the role foundation and the separately reviewed RPC migration
-- have been applied to an isolated staging database.
-- This script never assigns roles, calls privileged RPCs, or changes data.

with expected(function_name, identity_args, expected_guard) as (
  values
    ('admin_get_bookings', '', 'private.has_admin_role'),
    ('admin_get_kitchen_orders', '', 'private.has_admin_role'),
    ('admin_update_kitchen_order_status', 'p_order_id uuid, p_status text', 'private.has_admin_role'),
    ('confirm_booking', 'p_booking_id uuid', 'private.has_admin_role'),
    ('cancel_booking', 'p_booking_id uuid', 'private.has_admin_role'),
    ('add_service_order', 'p_user_id uuid, p_service_id uuid, p_quantity integer, p_comment text', 'private.has_owner_role'),
    ('create_manual_guest', 'p_name text, p_phone text, p_email text, p_city text, p_birth_date date, p_comment text', 'private.has_owner_role'),
    ('get_payment_history', 'p_booking_id uuid, p_order_id uuid', 'private.has_owner_role'),
    ('get_user_payment_history', 'p_user_id uuid', 'private.has_owner_role'),
    ('record_payment', 'p_booking_id uuid, p_order_id uuid, p_amount integer, p_payment_method text, p_note text', 'private.has_owner_role'),
    ('record_user_payment', 'p_user_id uuid, p_amount integer, p_payment_method text, p_note text', 'private.has_owner_role'),
    ('record_user_payment_for_charge', 'p_user_id uuid, p_charge_type text, p_charge_id uuid, p_amount integer, p_payment_method text, p_note text', 'private.has_owner_role')
),
actual as (
  select e.*, p.oid, p.prosrc, p.prosecdef, p.proconfig,
         has_function_privilege('anon', p.oid, 'EXECUTE') as anon_execute,
         has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_execute
  from expected e
  left join pg_proc p
    on p.pronamespace = 'public'::regnamespace
   and p.proname = e.function_name
   and pg_get_function_identity_arguments(p.oid) = e.identity_args
)
select function_name,
       identity_args,
       expected_guard,
       oid is not null as function_found,
       coalesce(prosecdef, false) as security_definer,
       coalesce(position(expected_guard in coalesce(prosrc,'')) > 0, false) as expected_guard_present,
       coalesce(position('auth.uid()' in coalesce(prosrc,'')) > 0, false) as uid_context_used,
       anon_execute,
       authenticated_execute,
       proconfig,
       case
         when oid is null then 'FAIL_MISSING_FUNCTION'
         when not prosecdef then 'FAIL_NOT_SECURITY_DEFINER'
         when position(expected_guard in coalesce(prosrc,'')) = 0 then 'FAIL_WRONG_ROLE_GUARD'
         when position('auth.uid()' in coalesce(prosrc,'')) = 0 then 'FAIL_NO_AUTH_UID_CONTEXT'
         when coalesce(anon_execute, true) then 'REVIEW_ANON_EXECUTE'
         when not coalesce(authenticated_execute, false) then 'REVIEW_AUTHENTICATED_EXECUTE'
         else 'PASS_STATIC_CHECKS'
       end as verification_status
from actual
order by expected_guard, function_name;

-- Helper-function hardening snapshot. Both helpers must be SECURITY DEFINER,
-- STABLE, and have a fixed pg_catalog search_path. Their EXECUTE ACLs must not
-- be granted directly to API roles: privileged RPCs call them as their owner.
select p.oid::regprocedure as helper_signature,
       p.prosecdef as security_definer,
       p.provolatile = 's' as stable,
       p.proconfig,
       has_function_privilege('anon', p.oid, 'EXECUTE') as anon_execute,
       has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_execute,
       coalesce(array_to_string(p.proacl, ','), '(default ACL)') as acl
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'private'
  and p.proname in ('has_admin_role', 'has_owner_role')
order by p.proname;

-- Manual identity matrix (use disposable staging accounts only):
-- 1. anon / missing JWT: all 12 functions denied.
-- 2. authenticated user with no private.user_roles row: all 12 denied.
-- 3. role='admin': five operational functions allowed; seven owner-only functions denied.
-- 4. role='owner': all 12 allowed, subject to each function's business validations.
-- 5. unknown/null role values cannot be inserted due to table constraint and must deny.
-- 6. Verify that role removal takes effect on the next request; do not rely on stale
--    app_metadata claims or client-side role state.
-- 7. Re-run the function inventory and compare function signatures, return types,
--    search_path, owner, and ACLs against the pre-migration snapshot.
