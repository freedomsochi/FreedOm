# Finance RPC coverage reconciliation

Date: 2026-11-27  
Branch: `fix/security-rpc-hardening-2026-11-26`  
Status: read-only production definition review plus source-only migration correction. No production database changes.

## Scope

Inspected live definitions, SECURITY DEFINER flags, function configuration and EXECUTE ACLs for:

- `add_service_order(uuid,uuid,integer,text)`
- `create_manual_guest(text,text,text,text,date,text)`
- `get_payment_history(uuid,uuid)`
- `get_user_payment_history(uuid)`
- `record_payment(uuid,uuid,integer,text,text)`
- `record_user_payment(uuid,integer,text,text)`
- `record_user_payment_for_charge(uuid,text,uuid,integer,text,text)`
- `record_event_registration_payment(uuid,integer,text)`

All eight were SECURITY DEFINER, owned by postgres, configured with `search_path=public`, and executable by authenticated. None was directly executable by anon in the inspected ACL snapshot.

## Coverage reconciliation

The first seven functions are already explicit targets in
`supabase/sql/20261127_admin_rpc_role_migration.sql`. They are classified owner-only
in `docs/security/admin-rpc-role-matrix.md`. A duplicate migration would be unsafe
and unnecessary. The role migration replaces their nullable fixed-email checks with
`auth.uid() IS NULL OR NOT private.has_owner_role()` and pins search_path to
`pg_catalog`. This remains source-only; the live role foundation was absent in the
last prerequisite check.

## Confirmed gap: event registration payment

The live body of `record_event_registration_payment(uuid,integer,text)` had no
authorization check at all, despite authenticated EXECUTE. The function locks an
event registration, inserts a payment and allocation, and updates paid amount/status.
This is a privileged financial mutation and should be owner-only pending an explicit
narrower policy decision.

The dedicated source migration and verification were corrected:

- Migration now requires `private.user_roles`, `private.has_owner_role()`, and at
  least one assigned owner before replacing the function. This prevents replacing
  the current guard before a recoverable owner role exists.
- The body now checks `auth.uid() IS NOT NULL` and
  `private.has_owner_role()`.
- Verification now checks the owner-role helper rather than a fixed-email guard.
- Function signature, return type, row lock, payment insertion, allocation insertion,
  balance/status update and grants are retained.

This also resolves a rollout conflict: the earlier event-payment migration would
otherwise have restored a fixed-email guard after the general role migration.

## Source commits

- Event payment migration: `074f130c89ce4d73242662e414027fb9e6fe488e`
- Event payment verification: `08c54d7bb2d075c27b6eec993273ab654eb441d0`
- Rollout runbook correction: `c9b6b42b4bea14fa4466f02d32a83ebe229420f1`

## Required staging tests

1. Apply role foundation in isolated staging and assign a test owner through the approved process.
2. Run the role migration, then the event payment migration.
3. Verify anon and ordinary authenticated users are denied.
4. Verify owner can post one payment and exactly one allocation against a disposable registration.
5. Verify amount validation, overpayment rejection, row locking and retry/duplicate behavior.
6. Run both verification scripts and inspect the final function definition and ACL.
7. Do not apply to production until staging, backup/restore and rollout approval are complete.

## Safety boundary

No live SQL writes, migration application, role assignment, financial data mutation or deployment
was performed. The live findings are a snapshot; re-check before staging rollout.
