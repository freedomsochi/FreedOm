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


## Additional verified access compatibility findings (live snapshot 2026-11-27)

A follow-up comparison of the inspected browser code with live table privileges and
`pg_policies` found several important compatibility gaps. These are not inferred
from GRANTs alone: the relevant live RLS policies were checked as well.

| Browser caller | Required access | Live access state | Consequence / safe action |
|---|---|---|---|
| `booking-sync.js` `resolveRoom()` | anon SELECT on `rooms(id,name,price_per_night)` | anon has no SELECT privilege on `rooms`; only `admin_all_rooms` exists for authenticated | Public booking room resolution is incompatible with current grants. Do not grant broad room SELECT; route through a narrowly scoped public RPC that returns only fields required for room selection. Existing `get_public_rooms()` omits `price_per_night`; do not assume it is a drop-in replacement. |
| `rooms-catalog.js` | anon/authenticated execute `get_rooms_catalog()` | RPC is SECURITY INVOKER, but anon/authenticated have no SELECT on `rooms` | Function EXECUTE alone does not make catalog work. The prepared migration `20261127_harden_public_room_catalog.sql` addresses this with a restricted SECURITY DEFINER projection; still source-only. |
| `profile.html` | authenticated SELECT `users.*` for current user | authenticated has no SELECT privilege on `users`; live policy list contains only fixed-email `admin_all_users` | User self-profile query is incompatible with current live access. Needs a narrow self-profile projection/RPC or explicit owner-row policy plus column minimization; do not simply grant SELECT *. |
| `purchases.html` | authenticated SELECT `orders.*` filtered by current `user_id` | SELECT grant exists, but only `admin_all_orders` policy exists and it is fixed-email | Ordinary signed-in users cannot read their own order rows under the inspected policy set. Needs a strict owner-row SELECT policy or restricted RPC. |
| `admin_v10_finance.html` | admin finance RPC + direct SELECT `users(user_id,Display_name,Phone,Email)` | direct SELECT is absent for authenticated; live policy is fixed-email ALL | Even after finance RPC role hardening, guest enrichment still depends on direct users access. Replace with a scoped RPC projection or explicitly approved column grants/policy. |
| `admin_v11_finance_detail.html` | direct SELECT bookings/orders/service_orders/event_registrations/payment_allocations, then owner-only payment RPC | Direct table policies are fixed-email; broad table grants exist | Admin role rollout must migrate corresponding RLS policies or the page will stop working for operational admins. Preserve successful-payment join semantics. |
| `admin_v11_services.html` | direct SELECT service_orders and successful payment allocations joined to payments | fixed-email policies on service_orders, payment_allocations and payments | Do not revoke SELECT until replaced by a service ledger RPC/view scoped to required columns. |
| `admin_v10_events.html` | direct SELECT events and event_registrations, including participant contact/payment fields | events has public SELECT; registrations has only fixed-email authenticated ALL policy | Admin event screen needs a deliberate role/column policy. Public event visibility patch should narrow event rows but must not expose registration data. |

### Important live privilege distinction

The current live `has_table_privilege` snapshot reports anon/authenticated SELECT
privileges on several tables (including orders, payments, allocations, service orders,
and event registrations), but RLS still limits visible rows. In particular,
`event_registrations` has no anon policy, and financial/admin tables have only
fixed-email authenticated policies. Conversely, `rooms` and `users` lack direct
SELECT privileges for anon/authenticated in the current snapshot. Never infer
effective row visibility from GRANTs without checking RLS, and never infer that
a missing policy is harmless for a user-facing page.

### Required remediation order

1. Restore public room selection through a minimal public RPC with exact required
   fields; do not expose the full `rooms` row.
2. Restore authenticated self-profile and own-order reads using row ownership
   checks based on `auth.uid()` and a verified mapping to the application user id;
   avoid `SELECT *` on personal/financial tables.
3. Replace admin finance and service direct reads with scoped projections, or
   explicitly map the minimum required columns and role policy.
4. Update event-admin registration access separately from public event listing.
5. Only after these changes, prepare table-level GRANT revocations. Preserve
   service_role and verified server-side integration paths.
6. Test anon, ordinary authenticated, admin, owner and service_role independently
   in staging. No production GRANT/RLS changes are authorized by this inventory.


## Source fix prepared: public booking room lookup

Commit `16bb26d254b85401af23dc5ede510a92f90585f4` updates
`booking-sync.js` so `resolveRoom()` uses the restricted
`get_rooms_catalog()` RPC instead of directly selecting from `public.rooms`.
It still receives the exact fields it uses (`id`, `name`,
`price_per_night`) and preserves room-name matching and booking submission.

Release dependency: this browser change must be deployed only together with
`supabase/sql/20261127_harden_public_room_catalog.sql` (or after that migration
has been verified in staging and applied in the approved release). The live
`get_rooms_catalog()` is still SECURITY INVOKER in the last inspected snapshot,
so deploying the JS change alone would fail. No database migration or deploy
was performed in this work session.
