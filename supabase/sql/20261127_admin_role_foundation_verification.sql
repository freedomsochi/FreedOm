-- FreeDom protected admin-role foundation verification
-- READ ONLY. Run only after the foundation migration is applied in staging.
-- This script asserts catalog/ACL properties; it does not assign roles or call
-- business RPCs and does not modify database state.

do $verify$
declare
  v_table oid := to_regclass('private.user_roles');
  v_helper oid := to_regprocedure('private.has_admin_role()');
begin
  if not exists (
    select 1 from pg_namespace n
    where n.nspname='private'
      and not has_schema_privilege('anon',n.oid,'USAGE')
      and not has_schema_privilege('authenticated',n.oid,'USAGE')
      and not has_schema_privilege('public',n.oid,'USAGE')
  ) then
    raise exception 'private schema is missing or exposed to PUBLIC/anon/authenticated';
  end if;

  if v_table is null then
    raise exception 'private.user_roles is missing';
  end if;

  if not (select c.relrowsecurity from pg_class c where c.oid=v_table) then
    raise exception 'RLS is not enabled on private.user_roles';
  end if;

  if has_table_privilege('anon',v_table,'SELECT,INSERT,UPDATE,DELETE')
     or has_table_privilege('authenticated',v_table,'SELECT,INSERT,UPDATE,DELETE')
     or has_table_privilege('public',v_table,'SELECT,INSERT,UPDATE,DELETE') then
    raise exception 'private.user_roles has client-facing table privileges';
  end if;

  if v_helper is null then
    raise exception 'private.has_admin_role() is missing';
  end if;

  if not (select p.prosecdef from pg_proc p where p.oid=v_helper) then
    raise exception 'private.has_admin_role() must be SECURITY DEFINER';
  end if;

  if has_function_privilege('anon',v_helper,'EXECUTE')
     or has_function_privilege('authenticated',v_helper,'EXECUTE')
     or has_function_privilege('public',v_helper,'EXECUTE') then
    raise exception 'private.has_admin_role() is executable by client roles/PUBLIC';
  end if;

  if not exists (
    select 1 from pg_proc p
    where p.oid=v_helper
      and coalesce(array_to_string(p.proconfig,','),'') ilike '%search_path=pg_catalog%'
  ) then
    raise exception 'helper search_path is not restricted to pg_catalog';
  end if;
end
$verify$;

-- Review role assignment metadata. Any rows must be traceable to an owner-approved
-- change; this query is informational and intentionally does not require zero rows.
select role, count(*) as assignments,
       count(*) filter (where created_by is null) as assignments_without_actor
from private.user_roles
group by role
order by role;

-- Remaining staging tests (manual, with disposable identities):
-- 1. As anon/authenticated non-admin, direct helper invocation must be denied.
-- 2. With no JWT subject, helper logic must resolve false (test in controlled
--    SQL/auth harness; do not impersonate a real owner).
-- 3. Admin and owner role rows resolve true; unknown roles are rejected by CHECK.
-- 4. Authenticated clients cannot SELECT/INSERT/UPDATE/DELETE role rows.
-- 5. Re-test every migrated admin RPC separately before rollout.
