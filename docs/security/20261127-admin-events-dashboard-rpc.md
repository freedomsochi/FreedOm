# Admin events dashboard RPC

## Purpose
Replace broad browser-side `events.select('*')` and `event_registrations` reads with one narrowly projected admin endpoint.

## Authorization
- Depends on the protected `private.has_owner_role()` helper from `admin-role-foundation.sql`.
- Requires a non-null `auth.uid()` and owner role.
- SECURITY DEFINER is used only because the helper and source tables are intentionally not exposed to ordinary clients; the body performs an explicit role check before reading any row.
- Fixed `search_path=pg_catalog`; all application relations are schema-qualified.
- EXECUTE is revoked from PUBLIC and anon and granted only to authenticated.
- The result includes explicit fields only. It omits event mentor profile fields and unrelated registration columns.

## Frontend
`admin_v10_events.html` now consumes `admin_get_events_dashboard()` and filters the returned registrations in memory for the selected event. It no longer makes direct browser queries to `events` or `event_registrations`.

## Release dependencies
1. Apply and verify role foundation in isolated staging.
2. Assign test owner identity using a separately controlled procedure; do not infer or hardcode a production identity.
3. Apply this migration in staging and run its verification query.
4. Test anonymous, ordinary authenticated, admin, and owner sessions. Only only owner may receive event and registration details.
5. Test empty events and multiple registrations per event, including modal detail rendering.
6. Do not apply to production or deploy frontend until staging passes and release is approved.

No production SQL or deployment was performed.
