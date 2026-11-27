# SECURITY DEFINER inventory — 2026-11-27

## Scope and safety

Read-only catalog audit of Supabase project `vutmbhsclmcfqqlzxqkc` on 2026-11-27. No database writes, migrations, grants, role assignments, or deployments were performed.

This is a catalog inventory, not a complete authorization proof. Function bodies, callers, data sensitivity, trigger dependencies, and intended service-role access still require review before changing permissions.

## Findings

- 44 non-system `SECURITY DEFINER` functions were returned across non-system schemas.
- 37? functions in `public` were enumerated separately; use the live catalog query below for the authoritative count rather than relying on this document's abbreviated listing.
- `anon` has EXECUTE on 7 public SECURITY DEFINER RPCs intended as public-facing endpoints: `confirm_public_booking`, `create_event_registration`, `create_public_booking`, `get_home_events`, `get_public_availability`, `get_public_room_availability`, `get_public_rooms`.
- The `public` schema has no CREATE privilege for PUBLIC, anon, or authenticated.
- All 15 `admin_*` SECURITY DEFINER functions are executable by authenticated; none is executable by anon. They all contain a fixed-email authorization check in their body (the check is written in multiple syntactic forms, so a single narrow regex does not detect all of them).
- The previously prepared role migration covered only 3 of those 15 admin-named functions, plus two booking mutation functions and seven owner-only finance/guest-management functions. It therefore does not cover the full admin RPC surface.

## Full admin-named inventory (15)

All below were observed in schema `public`, SECURITY DEFINER, authenticated EXECUTE = true, anon EXECUTE = false, and fixed-email authorization present:

1. `admin_get_bookings()`
2. `admin_get_bookings_overview()`
3. `admin_get_finance_overview()`
4. `admin_get_guest_dashboard_stats()`
5. `admin_get_guest_profile(p_user_id uuid)`
6. `admin_get_guests_overview()`
7. `admin_get_kitchen_orders()`
8. `admin_get_rooms()`
9. `admin_get_space_location(p_slug text)`
10. `admin_get_space_navigation()`
11. `admin_get_space_overview()`
12. `admin_get_user_debts()`
13. `admin_get_users()`
14. `admin_record_guest_payment(p_user_id uuid, p_amount integer, p_method text, p_charge_type text DEFAULT NULL, p_charge_id uuid DEFAULT NULL)`
15. `admin_update_kitchen_order_status(p_order_id uuid, p_status text)`

The prior 12-function migration included only `admin_get_bookings()`, `admin_get_kitchen_orders()`, and `admin_update_kitchen_order_status(uuid,text)` from this list. The remaining 12 admin-named functions must be classified and added to a complete role migration or explicitly documented as excluded with a security rationale.

## High-priority separate finding

`record_event_registration_payment(p_registration_id uuid, p_amount integer, p_payment_method text DEFAULT 'Перевод')` is SECURITY DEFINER in `public`, has EXECUTE for authenticated, and has no authorization check in its function body. It inserts a successful payment and allocation for a registration when the supplied registration ID is known and the business checks pass. An authenticated caller may therefore be able to record payments against registrations they do not control. This requires urgent caller/authorization review and a separate least-privilege remediation plan. Do not simply revoke or change it without confirming legitimate admin UI callers and rollback.

## Additional observations

- Several trigger-only functions and internal lookup functions are not executable by anon or authenticated; preserve their trigger execution semantics when changing ACLs.
- Public-facing booking, event-registration, availability, room, and home-event functions intentionally allow anon EXECUTE; they still require input validation, rate limiting/abuse review, data-minimization review, and safe search_path review.
- The initial role migration's proposed `search_path = pg_catalog` must not be applied blindly. Most inspected application functions explicitly schema-qualify their application tables, but every function body and nested helper call must be checked before adopting that setting.
- Do not assume every `admin_*` endpoint should share identical role access. Booking guest contact data, financial data, room occupancy, and payment mutation may warrant distinct capabilities and privacy decisions.

## Next actions (staging/source only)

1. Build a complete machine-readable inventory for every public SECURITY DEFINER function: identity signature, owner, proconfig, ACL, trigger dependencies, caller files, auth checks, and data sensitivity.
2. Prioritize `record_event_registration_payment`: trace all frontend/API callers, then prepare a role-guarded replacement plus explicit rollback and tests.
3. Expand the admin role matrix to all 15 admin-named functions; decide whether a single admin role is sufficient or whether finance/booking/content capabilities must be separated.
4. Rework the role migration and rollback to cover the approved full set, with exact signature and definition preconditions.
5. Test in an isolated staging database with guest, ordinary authenticated, admin, and owner identities before any production approval.

## Reproducible read-only catalog query

```sql
select
  p.oid::regprocedure as function_signature,
  n.nspname as schema_name,
  pg_get_userbyid(p.proowner) as owner_name,
  p.prosecdef as security_definer,
  p.proconfig as function_config,
  has_function_privilege('anon', p.oid, 'EXECUTE') as anon_execute,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_execute,
  pg_get_functiondef(p.oid) as definition
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where p.prosecdef
  and n.nspname not in ('pg_catalog', 'information_schema')
order by n.nspname, p.proname, p.oid::regprocedure::text;
```
