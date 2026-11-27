# Admin RPC role classification — review draft

Status: design artifact only. No database changes are applied by this document.

## Role model

- `owner`: full administrative authority, including financial records and guest identity management.
- `admin`: operational authority only, limited to explicitly approved booking and kitchen workflows.
- No role / unknown role / missing `auth.uid()`: deny.
- Public booking, availability, room catalog, and event discovery RPCs remain separate and must not be swept into the admin role migration.
- `service_role` integrations must be reviewed independently; do not infer that a function should be callable by service_role merely because it is SECURITY DEFINER.

## Candidate mapping for the 12 fixed-email RPCs

| RPC | Proposed minimum role | Reason / review note |
| --- | --- | --- |
| `admin_get_bookings()` | admin | Operational booking queue; returns guest contact data, so confirm that all operational admins are permitted to see it. |
| `admin_get_kitchen_orders()` | admin | Kitchen fulfilment queue; confirm returned fields do not expose unnecessary guest data. |
| `admin_update_kitchen_order_status(uuid,text)` | admin | Operational status transition only; preserve the existing allowed-status validation. |
| `confirm_booking(uuid)` | admin | Operational reservation confirmation; retain all overlap/capacity checks. |
| `cancel_booking(uuid)` | admin | Operational cancellation; retain the current restriction on confirmed/active bookings. |
| `add_service_order(uuid,uuid,integer,text)` | owner | Creates a charge-bearing service order; owner-only until a narrower operational policy is explicitly approved. |
| `create_manual_guest(text,text,text,text,date,text)` | owner | Creates a guest identity/profile and handles personal data. |
| `get_payment_history(uuid,uuid)` | owner | Exposes payment records and payment notes. |
| `get_user_payment_history(uuid)` | owner | Exposes a guest's consolidated payment history. |
| `record_payment(uuid,uuid,integer,text,text)` | owner | Writes a payment and allocation; financial mutation. |
| `record_user_payment(uuid,integer,text,text)` | owner | Writes and allocates a payment across charges. |
| `record_user_payment_for_charge(uuid,text,uuid,integer,text,text)` | owner | Writes a payment against a selected charge. |

This is a conservative proposal, not an approved policy. In particular, booking and kitchen visibility for operational admins needs an explicit privacy decision.

## Implementation requirements

1. Add role checks inside each privileged SECURITY DEFINER function; do not rely on client-side route hiding.
2. Use `private.has_admin_role()` only for the approved operational subset.
3. Use `private.has_owner_role()` for the owner-only subset.
4. Fail closed with an explicit `auth.uid() IS NULL` denial before sensitive work.
5. Preserve function signatures, return shapes, transaction semantics, business validation, and current intended service-role callers.
6. Keep EXECUTE ACLs least-privilege. Review each RPC independently; do not blanket-revoke public-facing RPCs or service integrations.
7. Set a safe fixed `search_path` and schema-qualify referenced objects in every SECURITY DEFINER function.
8. Test anon, authenticated non-admin, admin, owner, missing identity, and any intended service-role caller using disposable fixtures.
9. Capture before/after function definitions and ACLs. Include rollback/forward-repair steps.
10. Do not assign any owner/admin role or apply migrations to production as part of this source-only preparation.

## Evidence snapshot

The current database inspection found all 12 functions callable by `authenticated`, none callable by `anon` through direct EXECUTE ACL, and each still uses the fixed owner-email guard. The source migration that makes the guard NULL-safe is separate and does not yet introduce the role policy. Re-check this inventory immediately before generating the role migration because live schema and ACLs can change.


## Additional administrative RPCs discovered in the live inventory

These functions were separately identified in the 2026-11-27 live inventory. They are conservatively classified as owner-only because their result sets include guest identity/contact data, payment/debt details, occupancy information, or financial mutations. This is a staging proposal, not an approved production policy.

| RPC | Proposed minimum role | Reason |
| --- | --- | --- |
| `admin_get_bookings_overview()` | owner | Includes guest names, phones, emails, booking charges and payment summaries. |
| `admin_get_finance_overview()` | owner | Returns financial summaries, breakdowns and recent payments. |
| `admin_get_guest_dashboard_stats()` | owner | Aggregates guest, registration and debt totals. |
| `admin_get_guest_profile(uuid)` | owner | Returns an individual guest profile, bookings, orders, services, event registrations and payment history. |
| `admin_get_guests_overview()` | owner | Returns guest contact details and debt/payment summaries. |
| `admin_get_rooms()` | owner | Returns the full room rows; review column minimization before considering operational-admin access. |
| `admin_get_space_location(text)` | owner | May return current guest name/phone and room-level payment details. |
| `admin_get_space_navigation()` | owner | Returns the full published location graph and room metadata; confirm whether a restricted public projection is preferable. |
| `admin_get_space_overview()` | owner | Returns occupancy and guest information plus charged/paid/debt aggregates. |
| `admin_get_user_debts()` | owner | Exposes per-user debt. |
| `admin_get_users()` | owner | Returns full user rows, including personal data. |
| `admin_record_guest_payment(uuid,integer,text,text,uuid)` | owner | Creates a payment and allocation and updates charge balances. |

The source-only follow-up migration is `supabase/sql/20261127_harden_remaining_admin_rpcs.sql`; verify it with `supabase/sql/20261127_harden_remaining_admin_rpcs_verification.sql`. Do not widen any of these to the operational admin role without first reducing returned fields and documenting the minimum required access.
