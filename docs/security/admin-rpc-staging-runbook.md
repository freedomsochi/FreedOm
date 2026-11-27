# Admin RPC role migration — isolated staging runbook

**Status:** preparation only. The migration has not been applied to the live project.
**Production changes:** explicitly out of scope. Do not use the production project as staging.

## Current live-project baseline (read-only inspection, 2026-11-27)

- 12 target public SECURITY DEFINER RPCs are present.
- `private.user_roles`, `private.has_admin_role()`, and `private.has_owner_role()` are absent.
- Therefore the role foundation and role migration are not active in the live project.
- No role assignment, data change, or function replacement was performed by this inspection.

## Staging sequence

1. Provision an isolated Supabase staging project or branch only after confirming it has no additional cost. Do not create a paid resource without approval.
2. Restore a sanitized schema and synthetic test data. Do not copy guest PII, payment details, auth secrets, or production tokens.
3. Record a baseline of all 12 function definitions, signatures, defaults, return types, owners, ACLs, and `proconfig`.
4. Apply `supabase/sql/admin-role-foundation.sql`.
5. Create disposable Auth users for owner, admin, ordinary authenticated user, and anonymous testing. Verify each Auth UUID from the staging Auth console; never infer an ID from email or a display profile.
6. Assign the staging owner and admin roles using a separately reviewed, privileged staging-only operation. Do not grant client writes to `private.user_roles`.
7. Confirm exactly one or more valid owner rows exist. The RPC migration now aborts if there is no owner row; it never creates one or guesses an identity.
8. Apply `supabase/sql/20261127_admin_rpc_role_migration.sql`.
9. Run `supabase/sql/20261127_admin_rpc_role_verification.sql`. Resolve every FAIL/REVIEW status and inspect helper ACLs, owners, volatility, and fixed search paths.
10. Run the identity matrix below with disposable records. Confirm both allowed and denied calls.
11. Compare post-migration function signatures, defaults, return types, owners, ACLs, and business behavior with the baseline.
12. Exercise the rollback file only in a disposable staging clone, then rerun the legacy guard verification. Never treat rollback as an automatic production recovery path.

## Expected authorization matrix

| Identity | 5 operational RPCs | 7 sensitive/financial RPCs |
|---|---:|---:|
| anon / missing JWT | Deny | Deny |
| authenticated, no role | Deny | Deny |
| admin | Allow | Deny |
| owner | Allow | Allow |

Operational RPCs still return guest and booking information. The proposed admin scope therefore requires an explicit privacy decision before it can be enabled for real staff accounts.

## Functional tests

- Admin: list bookings; list kitchen orders; update a disposable kitchen order; confirm and cancel disposable bookings.
- Admin denied: create manual guest; create service order; read payment histories; record payments.
- Owner: repeat allowed operational tests and verify owner-only functions against synthetic records.
- Ordinary authenticated and anon: all 12 RPCs denied.
- Remove a disposable role and verify denial on the next request.
- Verify malformed/missing JWT and null `auth.uid()` fail closed.
- Verify no direct API-role EXECUTE on the private helpers and no direct API-role access to `private.user_roles`.
- Verify legitimate service-role/background integrations independently; do not add bypasses without a caller inventory and explicit test.

## Stop conditions

Stop and do not proceed if the staging environment is not isolated, if no verified owner identity exists, if any target function/signature differs from the allowlist, if helper/function owners differ, if any ACL changes unexpectedly, or if any negative authorization test succeeds when it should be denied.

## Rollback

`supabase/sql/20261127_admin_rpc_role_rollback.sql` is a manual staging-only recovery artifact. It restores the fixed owner-email guard using a NULL-safe comparison and restores the previous public search path. It does not remove role tables, helper functions, or role assignments. Verify the owner-email identity is still valid before using it.

## Approval boundary

This runbook, SQL artifacts, and read-only baseline checks do not authorize production migration, role assignment, booking/payment/auth changes, secret changes, paid staging resources, or deployment. Each requires a separately reviewed plan and explicit approval.
