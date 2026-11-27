# Security-definer and financial-data access inventory

Date: 2026-11-27  
Branch: `fix/security-rpc-hardening-2026-11-26`  
Scope: read-only audit of the live Supabase catalog and source-only remediation queue.

## Confirmed findings

1. **Legacy nullable email guards remain in the live database.** The following functions still use `if auth.email() <> 'serzh.xz@mail.ru' then`: `add_service_order`, `admin_get_bookings`, `admin_get_kitchen_orders`, `admin_update_kitchen_order_status`, `cancel_booking`, `confirm_booking`, `create_manual_guest`, `get_payment_history`, `get_user_payment_history`, `record_user_payment_for_charge`. Some are already included in source-only migration files; none of those source migrations have been applied to production.
2. **Event-registration payment RPC lacks an authorization guard in production.** `record_event_registration_payment(uuid,integer,text)` is SECURITY DEFINER and executable by authenticated users. Its body locks a registration and creates a successful payment/allocation. The source-only hardening migration for this RPC was prepared earlier; production remains unchanged.
3. **Event registration still performs phone-based account matching in production.** `create_event_registration` calls `find_user_by_phone` using visitor-supplied phone data. The trigger `attach_event_user_by_phone` also existed as an independent matching path. A source-only patch replaces both with verified-auth-contact linking; it has not been applied.
4. **Public booking confirmation remains a legacy email-claim guard.** `confirm_public_booking(uuid)` checks the JWT email claim and has anon EXECUTE revoked, but does not explicitly require non-null `auth.uid()`. A separate source-only patch was prepared earlier.
5. **Admin read RPCs expose guest and finance aggregates.** `admin_get_guest_profile`, `admin_get_finance_overview`, `admin_get_space_location`, `admin_get_space_navigation`, and `admin_get_space_overview` include explicit null-email rejection in their current definitions, but still use `search_path=public`. They should be moved to a pinned `pg_catalog, public` path after reviewing unqualified object references.
6. **Financial views:** `user_financial_summary` and `user_financial_breakdown` are marked `security_invoker=true`. The summary view has an explicit anon ACL entry, but its underlying `users`/financial-table RLS policies are admin-only. This is not evidence of anonymous data exposure by itself; it is an unnecessary public grant candidate. Do not revoke until frontend/API callers are checked.
7. **Sensitive base tables have RLS enabled.** Admin policies for users, bookings, orders, service orders, payments and event registrations use the administrator email predicate. The policies are fail-closed for a NULL email, but remain coupled to a fixed email and should eventually move to the role-table foundation.

## Remediation already staged (not applied)

- Nullable guard hardening for booking/payment-history RPCs: `20261127_harden_booking_and_payment_history_rpcs.sql`.
- Finance RPC hardening: `20261127_harden_finance_payment_rpcs.sql` and `20261127_harden_admin_rpc_guards.sql`.
- Event payment hardening: `20261127_harden_event_registration_payment.sql`.
- Verified contact account linking and event registration: `20261127_verified_contact_account_linking.sql`, `20261127_harden_public_event_registration.sql`.
- Public event/room catalog and public booking confirmation patches are staged separately.

## Safety boundary

All catalog queries were read-only. No production SQL, migration, table grant, policy, payment, user record, Edge Function, or deployment was changed. Do not apply the staged migrations as one blind batch: run them in a controlled staging database, execute their verification scripts, and test each frontend flow first.

## Next work

1. Finish caller mapping for the guest profile, finance, kitchen and space admin RPCs.
2. Confirm exact function signatures and result types in staging before applying any dynamic replacement.
3. Review the public grant on `user_financial_summary` against all frontend/API callers.
4. Consolidate staged migrations in dependency order; role foundation must precede role-based RPC conversion.
