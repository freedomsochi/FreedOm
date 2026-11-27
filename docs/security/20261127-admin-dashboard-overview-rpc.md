# Admin dashboard overview RPC

## Purpose
Replace direct dashboard reads from `users`, `events`, `event_registrations` and
`user_financial_summary` in `admin_v10_dashboard.html` with one role-checked RPC.

## Security
- Requires non-null `auth.uid()` and `private.has_admin_role()`.
- SECURITY DEFINER, fixed `search_path=pg_catalog`, schema-qualified relations.
- EXECUTE revoked from PUBLIC and anon; granted to authenticated.
- Returns aggregate guest/event counts, debt-only user IDs and amounts, five upcoming
  active events, and six latest registrations with limited event labels.
- Does not return guest phone/email or unrelated user fields.
- Existing `admin_get_bookings()` remains a separate protected call for actionable
  new booking cards. Booking mutations continue through the existing server API.

## Frontend
The dashboard now uses `admin_get_dashboard_overview()` and `admin_get_bookings()`.
The client-side fixed-email check was removed; the database role guard is authoritative.
Unauthenticated sessions still redirect to login.

## Release gates
1. Apply role foundation in isolated staging and assign test roles through the approved process.
2. Apply this RPC migration and run verification.
3. Test anon and ordinary authenticated denial; admin/owner access.
4. Compare guest/event/registration counts and samples against source tables.
5. Test zero events, no registrations, debt-free users, and time-zone boundary around current_date.
6. Confirm new booking cards still use the authorized bookings RPC and server action API.
7. Deploy only after all staging checks pass and release is approved.

No production SQL or deployment was performed.
