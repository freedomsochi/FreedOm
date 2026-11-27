# Admin guest, booking overview and payment RPC hardening

## Scope
The migration updates five remaining legacy RPCs:
- `admin_get_bookings_overview()` — admin role
- `admin_get_guest_dashboard_stats()` — admin role
- `admin_get_guest_profile(uuid)` — admin role
- `admin_get_guests_overview()` — admin role
- `admin_record_guest_payment(...)` — owner role only

All five move to `search_path=pg_catalog`, schema-qualified table references, and authenticated-only client EXECUTE. The guest profile response now returns only user_id, Display_name, Phone and Email, City rather than serializing every column of `public.users`.

## Existing page compatibility
- Booking map/list calls `admin_get_bookings_overview()`.
- Guest list calls `admin_get_guest_dashboard_stats()` and `admin_get_guests_overview()`.
- Guest profile calls `admin_get_guest_profile(uuid)`.
- Guest profile payment form calls `admin_record_guest_payment(...)`; the backend deliberately requires owner role, so an admin without owner role can view but cannot record payments.

## Staging requirements
1. Apply role foundation and assign an approved staging owner/admin.
2. Apply this migration after reviewing role assignment.
3. Run verification SQL.
4. Test anonymous, ordinary authenticated, admin and owner accounts.
5. Verify guest profile still renders identity, bookings, kitchen orders, services, events, debts and payment history.
6. Confirm only owner can submit a guest payment; admin can view guest profile and overview pages.
7. Exercise bookings map, filters and guest dashboard statistics.
8. Do not deploy updated client pages until the corresponding RPCs pass staging tests.

No production SQL or deployment was performed.
