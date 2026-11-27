-- FreeDom security hardening foundation
-- DESIGN / STAGING ARTIFACT ONLY. Do not run against production as-is.
-- Purpose: introduce a protected role source for later RPC-by-RPC authorization.
-- No role is assigned by this script. Owner/admin assignment is a separate owner-controlled action.

begin;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table if not exists private.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'admin')),
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);

alter table private.user_roles enable row level security;
revoke all on table private.user_roles from public, anon, authenticated;

create or replace function private.has_admin_role()
returns boolean
language sql
stable
security definer
set search_path = pg_catalog
as $$
  select exists (
    select 1
    from private.user_roles ur
    where ur.user_id = auth.uid()
      and ur.role in ('owner', 'admin')
  );
$$;

revoke all on function private.has_admin_role() from public, anon, authenticated;

-- Owner-only gate for sensitive financial and identity-management operations.
-- Keep this separate from has_admin_role(): operational admins must not
-- automatically inherit owner privileges.
create or replace function private.has_owner_role()
returns boolean
language sql
stable
security definer
set search_path = pg_catalog
as $
  select exists (
    select 1
    from private.user_roles ur
    where ur.user_id = auth.uid()
      and ur.role = 'owner'
  );
$;

revoke all on function private.has_owner_role() from public, anon, authenticated;

commit;

-- IMPORTANT:
-- 1. This file only establishes a protected role source and helper.
-- 2. It does NOT secure existing SECURITY DEFINER RPCs until each privileged
--    function body is changed to call private.has_admin_role() and its EXECUTE
--    grants are narrowed to the intended roles.
-- 3. Do not grant authenticated access to user_roles. Assign roles only through
--    an owner-controlled SQL operation after verifying the target auth.users.id.
-- 4. Keep public read-only RPCs (availability/events/catalog) separate from
--    administrative RPCs; do not revoke them in bulk.
-- 5. Before staging: inventory every SECURITY DEFINER function, map callers,
--    preserve legitimate service_role integrations, then test anon,
--    authenticated non-admin, admin, owner, NULL auth.uid(), and unknown role.
-- 6. Apply through a reviewed Supabase migration on an isolated branch first.
