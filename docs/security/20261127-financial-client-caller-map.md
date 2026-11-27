# Financial and guest-data client caller map

Status: source inspection of branch `fix/security-rpc-hardening-2026-11-26`, 2026-11-27.
This is a bounded caller map, not proof that every repository caller has been found.
No database changes applied.

## Current admin screens inspected

| File | Direct table access | RPC access | Notes |
|---|---|---|---|
| `admin_v10_finance.html` | `users` SELECT for guest contact fields | `admin_get_finance_overview()` | Financial overview RPC supplies summary/breakdown; client enriches user names/phone/email directly. |
| `admin_v11_finance_detail.html` | `bookings`, `orders`, `service_orders`, `event_registrations`, `payment_allocations` SELECT | `record_user_payment_for_charge(...)` | Reads a charge by both charge id and user id; reads successful allocations joined to payments; records payment through RPC. |
| `admin_v11_services.html` | `service_orders` and `payment_allocations` SELECT | — | Loads all service orders and their allocations. Fixed in this branch to count only allocations whose joined payment status is `успешно`; allocation-query errors are now surfaced instead of silently ignored. |
| `admin_v10_events.html` | `events`, `event_registrations` | — | Direct event and registration access; exact write actions require a separate detailed pass before changing grants. |
| `admin_kitchen.html` | — | `admin_get_kitchen_orders()`, `admin_update_kitchen_order_status(...)` | Uses RPCs for kitchen board and status transitions. |
| `admin_v5_vegraw.html` | `orders` SELECT | `record_payment(...)` | File labels itself a test version. Its presence alone does not prove it is unused; do not delete or revoke access based only on filename. |
| `admin_v11_bookings.html` | — | `admin_get_bookings_overview()` | Uses RPC for booking list. |

## Other observed callers

- `booking-sync.js` reads `rooms` and public `events`, and calls
  `create_public_booking()` and `create_event_registration()`. It does not
  directly write to payments or payment allocations in the inspected source.
- `rooms-catalog.js` calls `get_rooms_catalog()`.
- `admin_v10.html` calls `admin_get_guest_dashboard_stats()` and
  `admin_get_guests_overview()`.
- `purchases.html` reads `orders` and `purchases`; this is an additional
  direct order-table caller to retain in the grant review.
- `profile.html` reads `users` and `referrals`; its full field-level access
  must be considered before changing user grants.

## Security and accounting implications

1. Do not revoke direct SELECT on `users`, `orders`, `service_orders`,
   `event_registrations` or `payment_allocations` until all listed pages and
   any uninspected scripts have a replacement access path.
2. Direct admin reads are currently gated by fixed-email RLS policies on the
   inspected tables. Role-helper migration must cover both RPC guards and
   RLS policies; changing RPCs alone will not restore these direct reads for
   role-based admins.
3. Payment writes should remain mediated by narrowly scoped RPCs. The inspected
   payment detail flow uses `record_user_payment_for_charge`; the legacy
   Veg Raw test page uses `record_payment`. Review RPC guards and the legacy
   page's reachability before altering grants.
4. The kitchen screen uses RPCs and should not require broad direct access to
   payments or allocations.
5. This inventory is incomplete by design: root-level legacy/admin pages and
   dynamically loaded scripts still need reachability and caller analysis.
   Preserve old files until references and usage are proven absent.

## Completed source correction

In `admin_v11_services.html`, payment totals now join `payments` and filter
`payments.status = 'успешно'`, matching the successful-allocation rule used
by `admin_v11_finance_detail.html`. A failed allocation lookup is displayed
as an error rather than silently producing misleading paid totals.

Source commit: `3b635225e6840cbea38426d122c2db77b23e15c6`.
