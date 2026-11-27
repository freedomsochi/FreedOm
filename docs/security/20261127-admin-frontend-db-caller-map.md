# FreeDom — admin frontend to database access map

Date: 2026-11-27
Branch: fix/security-rpc-hardening-2026-11-26
Scope: source inspection of current admin pages and direct Supabase calls. This is a caller inventory, not a live authorization test.

## RPC caller map

| RPC | Browser caller(s) | Purpose / risk |
|---|---|---|
| admin_get_bookings | admin_v10_dashboard.html; admin_v11_bookings_mobile.html; admin_v12_bookings.html | Booking queue; guest PII and booking details. |
| admin_get_bookings_overview | admin_v11_bookings.html | Booking overview; guest PII. |
| admin_get_finance_overview | admin_v10_finance.html | Financial dashboard; owner-only unless a redacted admin view is explicitly designed. |
| admin_get_guest_dashboard_stats | admin_v10.html | Guest dashboard aggregates; determine if rows include identifying data. |
| admin_get_guests_overview | admin_v10.html | Guest CRM overview; personal data. |
| admin_get_guest_profile | admin_v14_guest_profile.html; guest_profile.js | Individual guest profile; personal and potentially financial data. |
| admin_get_kitchen_orders | admin_kitchen.html | Kitchen fulfillment queue; operational access may be admin, but guest fields should be minimized. |
| admin_update_kitchen_order_status | admin_kitchen.html | Operational status mutation; admin candidate. |
| record_user_payment_for_charge | admin_v11_finance_detail.html | Financial mutation; owner-only. |
| record_user_payment | admin_v8_users_crm.html; admin.html | Financial mutation; owner-only. |
| record_payment | admin_v8_users.html; admin_payments.html | Financial mutation; owner-only. |
| get_payment_history | admin_payments.html | Financial history; owner-only. |
| record_event_registration_payment | admin_v9_events.html | Financial mutation; owner-only. |
| admin_record_guest_payment | guest_profile.js | Financial mutation; owner-only. |

The earlier 12-RPC role migration does not cover the complete 15-function admin RPC surface. It must not be treated as a complete authorization rollout.

## Direct table access observed

| Page | Direct table access | Operations observed | Security/design consequence |
|---|---|---|---|
| admin_v9_events.html | events | SELECT, INSERT, UPDATE | Event content management can be admin. |
| admin_v9_events.html | event_registrations | SELECT, UPDATE | Current table mixes guest contacts, event status, payment status and amounts. Split operational edits from finance fields before granting admin-wide table access. |
| admin_v10_dashboard.html | users, events, event_registrations, user_financial_summary | SELECT | Direct reads include personal/financial sources; inspect view security and replace with purpose-built redacted dashboard RPC if admins need aggregates only. |
| admin_v11_finance_detail.html | bookings, orders, service_orders, event_registrations, payment_allocations | SELECT | Finance detail page reads multiple sensitive ledgers directly; owner-only. |
| admin_v8_users_crm.html | veg_raw_menu, services, rooms, users, bookings, orders, service_orders, payments | SELECT; INSERT into orders, service_orders, bookings | Mixed catalogue, CRM, fulfillment and financial scope. Needs endpoint separation; do not grant blanket admin ALL. |
| admin_v8_users.html | users, bookings, orders, service_orders, rooms, veg_raw_menu, payments, services | SELECT; INSERT into orders, service_orders, bookings | CRM and financial data are mixed with operational creation flows. |
| admin_payments.html | users, bookings, orders | SELECT | Sensitive guest and financial context; owner-only. |
| admin_v10_events.html | events, event_registrations | SELECT | Event reporting; registration query includes PII/financial columns unless explicit projection is narrow. |
| admin_v11_services.html | service_orders, payment_allocations | SELECT | Operational service queue is mixed with payment allocation data; separate operational view from finance ledger. |

## Key implementation decisions

1. Do not convert existing ALL policies to `has_admin_role()` as a blanket operation.
2. Admin candidates: event content management, kitchen order status, service fulfillment, room/service/menu catalogue maintenance. Grant only exact operations and only after checking selected columns and PII exposure.
3. Owner-only candidates: payments, payment allocations, transactions, purchases, user balances/debts, payment history, finance overview and payment mutations.
4. Mixed tables require a narrower API boundary:
   - `event_registrations`: admin may need event status/attendance; owner controls amount, paid_amount and payment_status.
   - `bookings`: admin may need check-in/out/status; owner controls payment and discount fields. Guest contact visibility needs an explicit privacy decision.
   - `orders`: admin may need items and fulfillment status; owner controls payment fields and ledger relations. Guest contact visibility needs an explicit privacy decision.
   - `service_orders`: admin may fulfill service orders; owner controls financial adjustments/allocations.
5. A table-level RLS policy cannot enforce column separation. Options are dedicated SECURITY INVOKER views with `security_invoker=true` where supported, narrowly scoped RPCs with explicit authorization and redacted return types, or column-level privileges combined with RLS. SECURITY DEFINER must not be used as a shortcut around RLS.
6. Inspect `user_financial_summary` view definition and grants before any admin dashboard role rollout. Views can bypass RLS by default unless configured with `security_invoker=true` on supported PostgreSQL versions.
7. Before release, verify every browser caller after the migration with anon, ordinary authenticated, admin, and owner sessions. Include read, insert, update, delete, and column-projection tests as applicable.

## Current status

- Source callsites inspected: 17 admin pages/scripts.
- Direct database caller map: documented above.
- Live DB schema/policies were queried read-only in the preceding audit.
- No live migrations, grants, policy edits, role assignments, payment writes, or deployments were performed.


## Follow-up: financial summary view and Data API grants (live read-only)

The `user_financial_summary` view is configured with `security_invoker=true`, which is the correct safer view mode. It exposes only user_id and aggregate charged/paid/debt/status values. However, catalog inspection found:
- `anon` has SELECT on `public.user_financial_summary`;
- `anon` does not have SELECT on `public.user_financial_breakdown`;
- `user_financial_breakdown` is also `security_invoker=true`;
- underlying `users`, `bookings`, `orders`, `service_orders`, `event_registrations`, `payments`, and `payment_allocations` have RLS enabled;
- the inspected sensitive-table policies are authenticated-only fixed-email admin policies; no anon policy was found for those tables.

This is not evidence of an anonymous financial-data disclosure: the invoker view's dependency privileges and underlying RLS should prevent anon access. The extra anon SELECT grant on the summary view is nevertheless unnecessary and confusing. Recommended staged cleanup: revoke anon SELECT on `user_financial_summary`, keep authenticated access only if its role/policy path is explicitly approved, and test the view as anon/ordinary authenticated/admin/owner. Do not revoke until any public callers are checked.

Catalog inspection also found table-level SELECT/INSERT privileges for anon and authenticated on several sensitive base tables (including orders, payments, payment_allocations, service_orders, and event_registrations), with RLS currently providing the row-level boundary. Treat these grants as an additional hardening review: reduce grants to the minimum operations actually needed by public booking/event flows, while retaining intended public API functions. Do not blanket-revoke until PostgREST and public flows are traced.

No live grants, policies, views, or data were changed.
