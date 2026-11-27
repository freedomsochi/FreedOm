# Finance RPC security review — 2026-11-27

## Critical finding prepared for remediation

`public.record_event_registration_payment(uuid, integer, text)` is SECURITY DEFINER and callable by `authenticated` and `service_role`. Its live body had no authorization check. It accepts an arbitrary registration UUID and writes a successful payment plus allocation; an authenticated account could therefore attempt to record payment against another guest's registration.

The admin events page `admin_v9_events.html` calls this RPC when an administrator increases the paid amount on an event registration. Source-only patch files:

- `supabase/sql/20261127_harden_event_registration_payment.sql`
- `supabase/sql/20261127_harden_event_registration_payment_verification.sql`

The patch requires a non-null `auth.uid()` and exact admin email match with `IS DISTINCT FROM`, pins `search_path=pg_catalog`, schema-qualifies application objects, preserves row locking and payment/allocation logic, and removes PUBLIC/anon execution while retaining authenticated/service_role.

## Related observations

Several other finance/admin SECURITY DEFINER RPCs use `auth.email() <> 'serzh.xz@mail.ru'`, which is NULL-permissive if a signed-in session has no email claim. These need the same null-safe identity check or, preferably, the planned database role-table authorization foundation. The role foundation is not installed in production.

## Safety

Repository-only changes on `fix/security-rpc-hardening-2026-11-26`. No production SQL was executed and no deployment was triggered. Before rollout, test admin success, non-admin denial, anonymous denial, partial/full allocations, and rollback in a safe environment.