# Fixed-email SECURITY DEFINER RPC inventory — 2026-11-27

## Live production snapshot

Read-only inspection of `public` found 25 SECURITY DEFINER functions whose bodies contain the legacy owner email. The role foundation is still absent in production:
- `private.user_roles`: absent
- `private.has_admin_role()`: absent
- `private.has_owner_role()`: absent

All 25 functions were executable by authenticated in the snapshot. Twenty-four were not executable by anon. The exception was `confirm_public_booking(uuid)`, which still had anon EXECUTE in the live snapshot; its body checks a fixed email and rejects callers without that claim, but the ACL is still unnecessarily broad.

## Covered by source migrations

### Operational admin / owner split — 12 RPCs
`20261127_admin_rpc_role_migration.sql` covers:
- `admin_get_bookings()`
- `admin_get_kitchen_orders()`
- `admin_update_kitchen_order_status(uuid,text)`
- `confirm_booking(uuid)`
- `cancel_booking(uuid)`
- `add_service_order(uuid,uuid,integer,text)`
- `create_manual_guest(text,text,text,text,date,text)`
- `get_payment_history(uuid,uuid)`
- `get_user_payment_history(uuid)`
- `record_payment(uuid,uuid,integer,text,text)`
- `record_user_payment(uuid,integer,text,text)`
- `record_user_payment_for_charge(uuid,text,uuid,integer,text,text)`

The minimum roles follow `docs/security/admin-rpc-role-matrix.md`: only the explicitly approved booking/kitchen operations are `admin`; charge creation, guest identity creation, payment history and payment mutation are `owner`.

### Sensitive CRM / occupancy — 12 RPCs
`20261127_harden_remaining_admin_rpcs.sql` covers:
- `admin_get_bookings_overview()`
- `admin_get_finance_overview()`
- `admin_get_guest_dashboard_stats()`
- `admin_get_guest_profile(uuid)`
- `admin_get_guests_overview()`
- `admin_get_rooms()`
- `admin_get_space_location(text)`
- `admin_get_space_navigation()`
- `admin_get_space_overview()`
- `admin_get_user_debts()`
- `admin_get_users()`
- `admin_record_guest_payment(uuid,integer,text,text,uuid)`

All 12 are owner-only. The follow-up
`20261127_admin_guest_booking_rpc_role_hardening.sql` only minimizes the guest
profile identity payload and adds a capability flag; it is not a second guard
migration. A staging-only rollback for the 12-function owner migration is
provided as `20261127_harden_remaining_admin_rpcs_rollback.sql`; it restores the
legacy email predicates but intentionally keeps `search_path=pg_catalog`.

## Remaining special case

`confirm_public_booking(uuid)` is intentionally not folded into either group
until its caller contract is confirmed. The source migration
`20261127_restrict_public_booking_confirmation.sql` pins its search path and
revokes EXECUTE from PUBLIC/anon while preserving authenticated/service_role
grants. A caller inventory must confirm that no anonymous or Edge Function
workflow depends on the current behavior before rollout. Do not claim the
fixed-email inventory is fully closed until this function is reviewed and the
anon grant is removed in staging.

## Release rule

This is a source/release inventory only. None of these migrations has been
applied to production. Apply the role foundation and all dependent migrations
only in isolated staging first, assign disposable test roles, verify every
allowed and denied path, then schedule an explicitly approved production change.
