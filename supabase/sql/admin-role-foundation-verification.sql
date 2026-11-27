-- FreeDom role foundation verification (READ ONLY).
-- Run only on an isolated staging database after admin-role-foundation.sql.
-- This script does not assign roles, grant access, or modify data.
--
-- Expected:
-- - private.user_roles exists, has RLS enabled, and has no client-facing policies.
-- - anon/authenticated/PUBLIC have no schema USAGE or table privileges.
-- - role helpers are SECURITY DEFINER, STABLE, pinned to pg_catalog, and
--   executable only by the trusted function owner (not API roles).
-- - both helpers read the role table as its owner.
-- - role values are constrained to owner/admin and user_id is unique.

with schema_state as (
  select n.oid,
         has_schema_privilege('anon', n.oid, 'USAGE') as anon_usage,
         has_schema_privilege('authenticated', n.oid, 'USAGE') as authenticated_usage,
         not exists (
           select 1
           from aclexplode(coalesce(n.nspacl, acldefault('n', n.nspowner))) a
           where a.grantee = 0 and a.privilege_type = 'USAGE'
         ) as public_usage_revoked
  from pg_namespace n
  where n.nspname = 'private'
),
table_state as (
  select c.oid,
         c.relrowsecurity,
         c.relforcerowsecurity,
         c.relowner,
         has_table_privilege('anon', c.oid, 'SELECT') as anon_select,
         has_table_privilege('anon', c.oid, 'INSERT') as anon_insert,
         has_table_privilege('authenticated', c.oid, 'SELECT') as authenticated_select,
         has_table_privilege('authenticated', c.oid, 'INSERT') as authenticated_insert,
         has_table_privilege('authenticated', c.oid, 'UPDATE') as authenticated_update,
         has_table_privilege('authenticated', c.oid, 'DELETE') as authenticated_delete,
         has_table_privilege('service_role', c.oid, 'SELECT') as service_select
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'private' and c.relname = 'user_roles' and c.relkind = 'r'
),
policy_state as (
  select count(*)::integer as policy_count
  from pg_policies
  where schemaname = 'private' and tablename = 'user_roles'
),
constraint_state as (
  select
    exists (
      select 1 from pg_constraint
      where conrelid = 'private.user_roles'::regclass
        and contype = 'p'
    ) as has_primary_key,
    exists (
      select 1 from pg_constraint
      where conrelid = 'private.user_roles'::regclass
        and contype = 'c'
        and pg_get_constraintdef(oid) ilike '%owner%'
        and pg_get_constraintdef(oid) ilike '%admin%'
    ) as has_role_check
),
helper_state as (
  select p.proname,
         p.oid,
         p.prosecdef,
         p.provolatile = 's' as is_stable,
         p.proconfig,
         p.proowner,
         has_function_privilege('anon', p.oid, 'EXECUTE') as anon_execute,
         has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_execute,
         has_function_privilege('service_role', p.oid, 'EXECUTE') as service_execute
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'private'
    and p.proname in ('has_admin_role', 'has_owner_role')
    and pg_get_function_identity_arguments(p.oid) = ''
),
helper_checks as (
  select
    count(*) = 2 as both_helpers_found,
    bool_and(prosecdef) as all_security_definer,
    bool_and(is_stable) as all_stable,
    bool_and(coalesce(array_to_string(proconfig, ','), '') ilike '%search_path=pg_catalog%') as all_pinned,
    bool_and(not anon_execute and not authenticated_execute and not service_execute) as no_api_execute,
    bool_and(proowner = (select relowner from table_state)) as helper_owned_by_role_table_owner
  from helper_state
)
select
  (select oid is not null from schema_state) as private_schema_found,
  (select not anon_usage and not authenticated_usage and public_usage_revoked from schema_state) as schema_closed_to_api_roles,
  (select oid is not null from table_state) as role_table_found,
  (select relrowsecurity from table_state) as rls_enabled,
  (select policy_count = 0 from policy_state) as no_client_policies,
  (select not anon_select and not anon_insert and not authenticated_select
          and not authenticated_insert and not authenticated_update and not authenticated_delete
   from table_state) as table_closed_to_anon_and_authenticated,
  (select has_primary_key and has_role_check from constraint_state) as role_constraints_valid,
  (select both_helpers_found from helper_checks) as both_helpers_found,
  (select all_security_definer from helper_checks) as helpers_security_definer,
  (select all_stable from helper_checks) as helpers_stable,
  (select all_pinned from helper_checks) as helpers_search_path_pinned,
  (select no_api_execute from helper_checks) as helpers_not_client_executable,
  (select helper_owned_by_role_table_owner from helper_checks) as helper_owner_matches_table_owner,
  case
    when not (select oid is not null from schema_state) then 'FAIL_PRIVATE_SCHEMA_MISSING'
    when not (select oid is not null from table_state) then 'FAIL_ROLE_TABLE_MISSING'
    when not (select relrowsecurity from table_state) then 'FAIL_RLS_DISABLED'
    when not (select not anon_usage and not authenticated_usage and not public_usage from schema_state) then 'FAIL_SCHEMA_EXPOSED'
    when not (select policy_count = 0 from policy_state) then 'FAIL_UNEXPECTED_ROLE_TABLE_POLICY'
    when not (select not anon_select and not anon_insert and not authenticated_select
                    and not authenticated_insert and not authenticated_update and not authenticated_delete
              from table_state) then 'FAIL_CLIENT_TABLE_PRIVILEGE'
    when not (select has_primary_key and has_role_check from constraint_state) then 'FAIL_ROLE_CONSTRAINT'
    when not (select both_helpers_found and all_security_definer and all_stable and all_pinned
                    and no_api_execute and helper_owned_by_role_table_owner from helper_checks)
      then 'FAIL_ROLE_HELPER_CONFIGURATION'
    else 'PASS_ROLE_FOUNDATION_STATIC_CHECKS'
  end as verification_status;

-- Review the current staging role assignment count. This is informational;
-- the expected test identities must be compared with the separately maintained
-- staging-only test-account ledger. Never copy production identities here.
select role, count(*) as assigned_test_accounts
from private.user_roles
group by role
order by role;

-- Confirm the check constraint definition and trigger-independent key structure.
select conname, pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid = 'private.user_roles'::regclass
order by conname;
