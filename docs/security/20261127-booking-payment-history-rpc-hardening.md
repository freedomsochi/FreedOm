# Booking and payment-history RPC hardening

Date: 2026-11-27  
Branch: `fix/security-rpc-hardening-2026-11-26`  
Status: prepared on the feature branch; **not applied to the live Supabase database**.

## Finding

The following SECURITY DEFINER functions used the nullable guard:

`if auth.email() <> 'serzh.xz@mail.ru' then`

When the JWT has no email claim, the comparison evaluates to NULL and PL/pgSQL does not enter the IF branch. That can let a caller with no email claim continue into privileged logic. The issue is especially sensitive for payment-history functions, which accept booking/order/user identifiers and return payment records.

Affected functions:
- `admin_get_bookings()`
- `cancel_booking(uuid)`
- `confirm_booking(uuid)`
- `get_payment_history(uuid,uuid)`
- `get_user_payment_history(uuid)`
- `admin_get_kitchen_orders()`
- `admin_update_kitchen_order_status(uuid,text)`

## Source patch

`supabase/sql/20261127_harden_booking_and_payment_history_rpcs.sql` replaces the guard with a fail-closed check requiring a non-null authenticated user ID and the expected administrator email. It also pins `search_path` to `pg_catalog`, removes EXECUTE from PUBLIC and anon, and retains EXECUTE for authenticated and service_role.

The migration aborts if any expected function or exact old guard is missing; it does not silently patch a different function body.

## Verification

Run `supabase/sql/20261127_harden_booking_and_payment_history_rpcs_verification.sql` after applying in a controlled staging environment. Expected: exactly seven rows; guard and search_path checks true; authenticated EXECUTE true; anon and PUBLIC EXECUTE false.

## Compatibility / remaining checks

- Existing frontend call sites use `get_payment_history` and the booking RPCs; signatures and return types are preserved.
- This is an interim hardening step using the existing administrator email identity. A role-table authorization model is still preferable and remains a separate staged migration.
- Do not apply to production until staging tests cover signed-in admin, ordinary authenticated user, missing-email/anonymous context, and booking/payment UI flows.
- No production database changes or deployments were performed for this patch.
