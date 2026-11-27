# Public booking confirmation RPC caller audit — 2026-11-27

## Live production definition (read-only)
The live `public.confirm_public_booking(uuid)` is SECURITY DEFINER with `search_path=public`. It checks the JWT email against the legacy owner email before loading and confirming a booking. The live ACL snapshot showed:
- `anon`: EXECUTE = true
- `authenticated`: EXECUTE = true
- `service_role`: EXECUTE = true

The anonymous grant is unnecessary: an anonymous JWT cannot satisfy the function's fixed-email check. The broad grant still exposes an unnecessary callable SECURITY DEFINER endpoint.

## Tracked-repository caller scan
No direct invocation of `confirm_public_booking` was found in the relevant tracked booking paths inspected:
- `booking_form_v2.html`
- `booking-sync.js`
- `api/booking.js`
- `api/admin-booking.js`
- `admin_booking_actions.js`
- `admin_v11_bookings.html`
- `admin_v12_bookings.html`
- `admin_bookings_mobile.html`
- `admin_v14_occupancy.html`

The public booking flow calls `create_public_booking`. The current admin booking API calls `confirm_booking` or `cancel_booking`. Neither path uses `confirm_public_booking`. No matching in-repository Edge Function source was found in this branch. This is a tracked-repository scan, not proof that no external or dashboard-configured caller exists.

## Source-only hardening
`supabase/sql/20261127_restrict_public_booking_confirmation.sql` now:
- requires `private.has_owner_role()` and non-null `auth.uid()`;
- pins `search_path=pg_catalog`;
- revokes EXECUTE from PUBLIC, anon and service_role;
- grants EXECUTE only to authenticated.

Prerequisite: apply `admin-role-foundation.sql` in isolated staging and assign an owner role to the disposable test operator. The verification script checks the body guard, search path and all four ACL conditions. The rollback restores the old email predicate only; it deliberately keeps the fixed search path and authenticated-only ACL.

## Release decision
Treat this as owner-only, not public. In staging, test an owner success, authenticated non-owner denial, anonymous denial, and service-role denial. Also verify that public booking creation and admin booking actions still work through their separate RPCs. Do not apply to production without explicit approval.
