# Admin finance charge detail RPC

## Purpose
Replace direct browser reads from `bookings`, `orders`, `service_orders`,
`event_registrations`, `payment_allocations` and `payments` in
`admin_v11_finance_detail.html` with `admin_get_finance_charge_detail(text,uuid)`.

## Authorization and data minimization
- Requires a non-null `auth.uid()` and `private.has_admin_role()` in the function body.
- SECURITY DEFINER with fixed `search_path=pg_catalog`; all relations are schema-qualified.
- EXECUTE revoked from PUBLIC and anon; granted only to authenticated.
- Charge type is allowlisted to booking/order/service/event; unknown types are rejected.
- The URL `user_id` parameter is no longer used to select a charge or authorize access. The actual owner ID is returned by the role-checked RPC and is used only for the profile link/payment RPC.
- Only the fields needed for the detail page are returned. Payment history includes successful allocations only and limited payment metadata.

## Frontend
The detail page calls the RPC once, renders the charge and successful allocation history, and preserves the existing
`record_user_payment_for_charge` payment action. That mutation remains separately guarded by the owner-only role
migration; operational admin permission to inspect a charge does not imply permission to post a payment.

## Release gates
1. Apply role foundation in isolated staging, assign test admin and owner identities through the approved process.
2. Apply the RPC migration and run its verification query.
3. Test anon and ordinary authenticated denial; admin and owner read access; all four charge types; missing IDs and invalid types.
4. Compare totals and allocation history against known fixtures, including pending payments (which must not count).
5. Verify ordinary admin can inspect but cannot post payments unless separately assigned owner.
6. Deploy the frontend only after staging validation and explicit release approval.

No production SQL, role assignment, or deployment was performed.
