| 6 || 7 || 8 || 9 || 10 || 11 || 6 || 7 || 8 || 9 || 10 || 11 || 12 |# FreeDom Supabase security rollout runbook

Date: 2026-11-27  
Branch: `fix/security-rpc-hardening-2026-11-26`  
Status: planning and source review only. Nothing in this runbook has been applied to the production database.

## Safety boundary

The connected Supabase project is production. Do not execute any migration in this list against production without a separately approved change window, verified backup/restore plan, and a reviewed staging run. Do not deploy Edge Functions as part of this database sequence. Do not rewrite financial balances or detach existing user links automatically.

## Migration inventory and dependency order

| Order | SQL file | Purpose | Dependency / rollout note |
|---:|---|---|---|
| 1 | `supabase/sql/admin-role-foundation.sql` | Create private role table and role-check helpers | Must precede any migration that calls `private.has_admin_role()` or `private.has_owner_role()`. No role assignments are included; admin and owner assignment must be separately reviewed. |
| 2 | `supabase/sql/20261127_harden_booking_and_payment_history_rpcs.sql` | Harden seven booking/payment/kitchen RPC guards and grants | Can run before or after step 3. It preserves an already-installed matching `private.has_admin_role()` or `private.has_owner_role()` guard on overlapping functions; otherwise it installs the fail-closed email guard. |
| 3 | `supabase/sql/20261127_admin_rpc_role_migration.sql` | Replace email checks with database role checks for its covered RPC subset | Depends on step 1. Accepts either the legacy email guard or the fail-closed guard from step 2. This is one of the two role-migration groups; the separate follow-up covers 12 additional administrative read/payment RPCs. |
| 4 | `supabase/sql/20261127_harden_remaining_admin_rpcs.sql` | Convert 12 remaining admin read/payment RPCs to owner-role checks | Depends on role foundation and owner assignment in isolated staging. Conservative owner-only scope because results include guest identity, financial history, or occupancy details. Run its matching verification script. |
| 5 | `supabase/sql/20261127_harden_event_registration_payment.sql` | Add owner-role authorization to event payment mutation RPC | Depends on step 1 and a separately assigned owner in staging; verification checks `private.has_owner_role()`. This RPC previously had no body-level authorization check. |
| 6 | `supabase/sql/20261127_harden_public_event_registration.sql` | Remove phone-only account linking from registration RPC and trigger | Test both anonymous and signed-in registration, verified and unverified phone, and existing user_id preservation. |
| 7 | `supabase/sql/20261127_verified_contact_account_linking.sql` | Harden other contact-based trigger linking | Coordinate with step 5; test all five trigger functions and preserve pre-existing links. |
| 8 | `supabase/sql/20261127_harden_public_room_catalog.sql` | Provide a restricted public room-catalog RPC matching frontend fields | Test anon room catalog, booking form, image and booking_mode fields. |
| 9 | `supabase/sql/20261127_restrict_public_event_visibility.sql` | Limit public event rows to active/home-visible | Test public event listing, event detail and admin writes; row policy does not restrict columns. |
| 10 | `supabase/sql/20261127_restrict_public_booking_confirmation.sql` | Remove anon access to privileged booking confirmation | Before rollout, confirm no legitimate anonymous caller exists; authenticated admin flow must still work. |
| 11 | `supabase/sql/20261127_pin_admin_read_rpc_search_path.sql` | Pin search_path on 12 admin read RPCs | Test all admin screens and confirm unqualified object/function references resolve under `pg_catalog, public`. |
| 12 | `supabase/sql/20261127_revoke_anon_financial_summary_view.sql` | Remove unnecessary anon SELECT from sensitive finance summary view | Only after checking all website/admin callers; authenticated admin and service-role access must remain. |

## Per-migration staging gates

For each migration, use a fresh staging snapshot and perform the following before proceeding:

1. Record the pre-change definitions, owners, grants, RLS policies and relevant row counts.
2. Apply only one logical migration group at a time; do not batch unrelated changes.
3. Run its matching `*_verification.sql` file (where present) and require every assertion to pass.
4. Run Supabase security advisors and compare with the baseline; explain every new warning.
5. Exercise both allowed and denied paths. A denied path must fail closed and must not silently return or mutate data.
6. Test browser workflows: public rooms, event listing/registration, booking, admin booking, kitchen, guest profile, finance and space navigation.
7. Confirm no duplicate registrations/payments, no changed financial balances, and no altered existing user_id links.
8. Save logs, SQL output and a rollback decision before moving to the next group.

## Mandatory test cases

### Roles and administrative RPCs
- Anonymous caller denied on every admin RPC.
- Ordinary authenticated user denied on every admin RPC and admin table policy.
- Assigned admin can read and perform only the intended operational tasks.
- Assigned owner can execute owner-only operations; admin-only cannot implicitly gain owner rights.
- Missing, NULL, malformed or stale auth claims fail closed.
- No role assignment is created by migration; assignments are separately authorized and audited.

### Public booking and catalog
- Anonymous visitor can read only the intended room catalog and active public events.
- Anonymous visitor can create a booking through the intended Edge Function/RPC contract.
- Anonymous visitor cannot confirm/cancel an existing booking or read guest/finance records.
- Room catalog field names and booking_mode remain compatible with `rooms-catalog.js`.
- No public policy exposes inactive or non-home events.

### Event registrations and payments
- Anonymous registration works without assigning an unrelated existing account by phone.
- Signed-in registration links only to the current user when Auth phone is verified and matches.
- Existing non-null user_id is never overwritten by a phone match.
- Event payment RPC rejects anon and ordinary authenticated users.
- Admin event payment writes exactly one payment and one allocation; retry behavior is explicitly tested for duplicate submissions.

### Financial views and records
- Anonymous SELECT on `user_financial_summary` is denied after the grant patch.
- Admin finance dashboards continue to work.
- Pending payments do not count as collected or paid allocations; successful allocations reconcile with payment records.
- No migration rewrites `paid_amount`, payment history, allocations, debts or user ownership.

## Known blockers / not yet cleared

- No staging environment has been verified for this project.
- Role foundation exists only as source; live `private.user_roles` and helpers were absent in the last audit.
- The initial role migration covers 12 operational/owner RPCs; a separate source-only follow-up now covers 12 additional admin read/payment RPCs conservatively as owner-only. Neither set has been tested in staging or applied to production.
- Frontend caller inventory remains incomplete because GitHub code search returned no indexed matches for key RPC/view names. Do not infer that no callers exist.
- `user_financial_summary` anon grant is unnecessary, but caller compatibility still needs explicit source review before production rollout.
- The Edge Function `telegram-notify` auth change is a separate coordinated deployment and is intentionally excluded here.
- Existing finance discrepancies are audit findings only; never auto-correct them as part of security rollout.

## Completion definition

The security rollout is complete only when staging verification passes, all frontend flows pass, every admin/owner RPC is covered by a role/authorization matrix, advisors show no unexplained new findings, rollback steps are tested, and production rollout is separately approved.


## Migration overlap review

The two contact-linking migrations both replace `public.attach_event_user_by_phone()`. The event-registration migration removes phone-based account discovery; the verified-contact migration installs the final trigger-only definition and revokes direct client EXECUTE on all five trigger functions. Therefore the listed order (event-registration migration first, verified-contact migration second) is intentional. Do not reverse the order. After both migrations, verify the final trigger body still checks `auth.uid()`, `phone_confirmed_at`, and exact normalized phone equality, and that client EXECUTE remains revoked. Both definitions preserve existing non-null `user_id` values.

The seven-function booking/payment hardening migration and the 12-function admin role migration overlap on five RPCs: `admin_get_bookings()`, `admin_get_kitchen_orders()`, `admin_update_kitchen_order_status(uuid,text)`, `confirm_booking(uuid)`, and `cancel_booking(uuid)`. This overlap is now handled in both directions: the booking/payment migration preserves an existing matching `private.has_admin_role()` or `private.has_owner_role()` guard, while the role migration accepts either the original nullable email guard or the fail-closed email guard installed by the booking/payment migration. Therefore either order is safe; keep steps 2 and 3 adjacent and run both matching verification scripts after both migrations. The two payment-history RPCs are also in the role migration's owner-only subset, so the role migration accepts their hardened email guard too.

The 12-function admin role migration pins `search_path=pg_catalog`. The live bodies inspected for its 12 targets use schema-qualified `public.*` table/function references and qualified `auth.*` helpers; keep this property when reviewing any future target added to the migration. Never broaden the search_path to include writable schemas merely to make an unqualified reference resolve.


## Remaining admin RPC classification

The follow-up migration `20261127_harden_remaining_admin_rpcs.sql` assigns the owner-only helper to the remaining 12 functions: booking overview, finance overview, guest dashboard stats/profile/overview, room list, space location/navigation/overview, user debts/users, and guest payment recording. This is intentionally conservative: several read RPCs expose guest phone/email, payment history, debt, or current room occupancy. Operational-admin access to any subset requires a separate privacy review and explicit policy decision. The migration preserves function signatures, return shapes, business logic, and existing grants; it changes authorization guards and pins `search_path=pg_catalog`. It requires an already assigned owner in staging and must be verified with `20261127_harden_remaining_admin_rpcs_verification.sql`.


## Financial table grants and RLS follow-up

The read-only inventory in `docs/security/20261127-financial-table-grants-and-rls-audit.md` found RLS enabled on all inspected base tables and `security_invoker=true` on both financial views. No anon RLS policy appeared for the inspected financial/guest tables. However, direct grants remain broader than necessary: anon and authenticated have extensive DML/REFERENCES/TRIGGER/TRUNCATE grants on payments, payment allocations, orders, service orders and event registrations; the summary view also has broad anon grants. RLS limits row access but does not govern TRUNCATE, REFERENCES or TRIGGER privileges. Do not revoke these grants blindly: finish the browser/Edge/admin caller inventory first, then prepare a narrow grant migration and test it in staging. The inventory does not establish a confirmed anon data leak.


## Client caller map and service-payment display correction

The bounded source caller inventory is in
`docs/security/20261127-financial-client-caller-map.md`. It identifies direct
reads of `users`, `orders`, `service_orders`, `event_registrations` and
`payment_allocations`, as well as RPC-mediated kitchen and payment actions.
It is not a complete proof of reachability or an exhaustive search of every
legacy page. Keep the legacy files until their links and usage are proven absent.

A source-only correction in `admin_v11_services.html` now counts only
`payment_allocations` linked to payments with status `успешно`, consistent
with the finance detail page and the reconciliation rule. The page now surfaces
allocation query failures instead of silently showing misleading paid totals.
Commit: `3b635225e6840cbea38426d122c2db77b23e15c6`.

Next grant work must preserve the observed direct reads until they are replaced
with appropriately scoped RPCs or views. In particular, role-based admin RLS
migration must account for direct table reads as well as SECURITY DEFINER RPCs.


## Finance RPC coverage reconciliation

The live function-definition review on 2026-11-27 confirms that the seven finance/guest RPCs
`add_service_order`, `create_manual_guest`, `get_payment_history`,
`get_user_payment_history`, `record_payment`, `record_user_payment`, and
`record_user_payment_for_charge` are already included in the 12-function role migration
(step 3) as owner-only targets. Do not create a duplicate migration for them.

A separate gap was confirmed for `record_event_registration_payment(uuid,integer,text)`:
it was SECURITY DEFINER, executable by authenticated, and had no authorization check in
its live body. Its dedicated hardening migration (step 5) now uses
`private.has_owner_role()`, checks that the role foundation and at least one owner
assignment exist before replacing the function, and has a matching verification query.
This avoids the prior rollout hazard where a later event-payment migration could have
replaced a role-based guard with a fixed-email guard. The event-payment migration remains
source-only and must run after role foundation and owner assignment in isolated staging.

Live inventory also showed these seven owner-target RPCs still use `search_path=public`
and fixed-email guards before rollout. The coordinated role migration pins their path to
`pg_catalog` and replaces those guards; it has not been applied. Do not treat this
source-level coverage as a production fix.


## Direct browser access compatibility gate

The 2026-11-27 follow-up compared the current browser source with live SELECT
privileges and RLS policies. This is now a mandatory gate before any table GRANT
revocation or role-policy rollout:

- Public booking currently resolves a room by direct `rooms` SELECT, but anon
  lacks SELECT on that table. Replace this with a narrowly scoped public RPC;
  `get_public_rooms()` does not currently return the price field used by the
  browser's notification calculation.
- `rooms-catalog.js` calls SECURITY INVOKER `get_rooms_catalog()`, whose
  underlying `rooms` SELECT is not available to anon/authenticated. The
  source-only catalog migration must be staged and tested before release.
- `profile.html` selects `users.*`, while authenticated has no SELECT privilege
  on `users` in the live snapshot. Design a self-profile projection; do not
  grant the full users row to every authenticated account.
- `purchases.html` selects `orders.*` by user_id, but the only live orders
  policy is fixed-email admin ALL. Add a strict own-row access path after
  verifying the Auth UID to application user_id mapping.
- `admin_v10_finance.html` enriches finance RPC results with a direct users
  SELECT; `admin_v11_finance_detail.html`, `admin_v11_services.html`, and
  `admin_v10_events.html` also rely on direct reads behind fixed-email RLS.
  Role RPC guards alone will not migrate these pages to the new admin/owner
  model. RLS policies and any required column projections must be handled as
  a separate coordinated workstream.

See `docs/security/20261127-financial-client-caller-map.md` and
`docs/security/20261127-financial-table-grants-and-rls-audit.md` for the
verified per-page matrix. These findings are read-only snapshots; they do not
prove every legacy page is reachable, and no broad grant or policy change should
be made until each caller has a tested replacement.


## 2026-11-27 follow-up — admin dashboard read-path consolidation

Source-only additions:
- `admin_get_events_dashboard()`: replaces direct reads from `events` and `event_registrations` in `admin_v10_events.html`.
- `admin_get_services_dashboard()`: replaces direct reads from `service_orders` and `payment_allocations` in `admin_v11_services.html`; only successful payment allocations are counted.
- Each RPC has a verification and manual rollback SQL file plus a dedicated security note.
- Both RPCs require non-null `auth.uid()` and `private.has_admin_role()`, pin `search_path=pg_catalog`, and revoke execution from PUBLIC/anon.

**Hard production blocker confirmed by read-only query (2026-11-27):** `private.has_admin_role()`, `private.has_owner_role()`, and the new dashboard RPCs do not exist in production. The role foundation has not been applied. These frontend pages must not be deployed independently of the staging migration sequence.

**Security advisor snapshot (2026-11-27):** 7 anon-executable SECURITY DEFINER functions, 32 authenticated-executable SECURITY DEFINER functions, and leaked-password protection disabled. The anon list includes expected public endpoints (`create_public_booking`, `create_event_registration`, availability/catalog/home-events) as well as `confirm_public_booking`, which already has a source-only restriction migration. The authenticated list includes admin RPCs whose authorization is being hardened through the role migration. Do not bulk-revoke EXECUTE: classify each function by intended public/admin/service caller and preserve legitimate public flows.

Staging gate remains mandatory: establish role foundation, assign disposable admin/owner identities, apply all dependent RPC migrations, test anon / ordinary authenticated / admin / owner, then approve a coordinated frontend release. No production SQL or deployment was performed.


## 2026-11-27 follow-up — finance admin read consolidation

Two additional source-only RPC changes are now prepared:

- `admin_get_finance_charge_detail(text,uuid)` replaces direct detail reads from bookings, orders, service orders, event registrations, payment allocations and payments in `admin_v11_finance_detail.html`. It requires `private.has_admin_role()`, restricts the charge type, and returns successful allocation history only.
- `admin_get_finance_overview()` now includes a minimal `users` projection (user_id, Display_name, Phone, Email) for finance-summary users. `admin_v10_finance.html` consumes that payload and no longer queries `public.users` directly.

Both changes are source-only, include verification SQL and security notes, and depend on the role foundation. Static source checks passed. The live production role helper and new finance-detail RPC remain absent; no migration or frontend deployment has been performed. The finance overview's existing live implementation still uses a fixed-email guard and `search_path=public`; the new migration replaces that guard with the role check only after staging role setup.

The charge-detail page preserves the existing payment mutation call. Viewing a charge as an operational admin does not grant payment-write authority; that write remains separately owner-gated by the role migration.


## 2026-11-27 follow-up — admin overview dashboard consolidation

The source-only `admin_get_dashboard_overview()` migration replaces the remaining
direct dashboard reads from `users`, `events`, `event_registrations` and
`user_financial_summary` in `admin_v10_dashboard.html`. It returns aggregate
counts, debt-only IDs/amounts, five upcoming active events and six latest
registrations with limited event labels. The frontend retains the separate
`admin_get_bookings()` call for actionable booking cards and removes the
client-side fixed-email gate; the database role check is authoritative.

Static checks passed: no direct table reads remain on this dashboard, the
overview RPC checks `auth.uid()` and `private.has_admin_role()`, uses
`search_path=pg_catalog`, and grants EXECUTE only to authenticated. The
migration remains source-only and depends on the role foundation. Production
was not changed and the updated page must not be deployed before staging tests.


## 2026-11-27 follow-up — guest and booking RPC authorization

A further source-only migration now covers five remaining RPCs used by the guest list, guest profile, and bookings map:

- `admin_get_bookings_overview()`, `admin_get_guest_dashboard_stats()`, `admin_get_guest_profile(uuid)`, and `admin_get_guests_overview()` require the admin role.
- `admin_record_guest_payment(...)` requires the owner role, preserving the separation between CRM administration and financial mutation.
- All five use `search_path=pg_catalog`, and their browser EXECUTE grants are limited to authenticated users.
- Guest profile no longer serializes the entire `users` row; it returns only user_id, display name, phone, email and city. It also returns `can_record_payments`; the page now hides the payment form from non-owners and explains the restriction.

The booking map, guest list, guest profile, kitchen, finance, services and events pages were inspected. The kitchen screen already uses only `admin_get_kitchen_orders()` and `admin_update_kitchen_order_status()`; the existing role migration covers both as admin-role functions. The guest profile and booking overview were the remaining legacy fixed-email guards identified in this pass.

Static checks for the five-function migration and owner-aware payment UI passed. This is source-only: role foundation is still absent in production, and no SQL or deployment was performed.


## Role policy clarification — sensitive CRM pages remain owner-only

The 2026-11-27 role matrix is the source of truth for minimum privileges. Operational `admin` is limited to approved booking and kitchen actions. Guest lists/profiles, guest-linked bookings overview, event registrations with contact/payment details, services, debts, finance summaries and charge details require `private.has_owner_role()`.

The consolidated guest/booking follow-up was narrowed to a response-minimization migration only; the 12-function owner-role migration `20261127_harden_remaining_admin_rpcs.sql` is the prerequisite that actually replaces those legacy guards. The follow-up does not attempt to replace the same authorization guards a second time. It removes full-row serialization from the guest profile identity object and exposes an owner payment capability flag for the UI.


## Superseding role-policy correction (2026-11-27)

This section supersedes earlier follow-up notes that described the new guest, dashboard, event, services or finance RPCs as `admin`-accessible. The role matrix is authoritative: guest identity, guest-linked bookings, debt, event-registration contact/payment data, service orders and all financial charge details are **owner-only**. Only the explicitly enumerated operational booking/kitchen RPCs in `admin_rpc_role_matrix.md` use the `admin` role.

Accordingly, these source migrations now require `private.has_owner_role()`:
- `20261127_admin_dashboard_overview_rpc.sql`
- `20261127_admin_events_dashboard_rpc.sql`
- `20261127_admin_services_dashboard_rpc.sql`
- `20261127_admin_finance_overview_guest_identity_rpc.sql`
- `20261127_admin_finance_charge_detail_rpc.sql`

The existing `20261127_harden_remaining_admin_rpcs.sql` is the single owner-role guard migration for the 12 legacy guest/finance/space RPCs. The similarly named `20261127_admin_guest_booking_rpc_role_hardening.sql` is only a follow-up to minimize the guest profile identity payload and add a UI capability flag; it no longer duplicates or changes authorization guards. Apply the 12-RPC migration before that payload follow-up.

The guest profile itself remains owner-only under the current policy. The `can_record_payments` flag is defense-in-depth for the form and supports a possible future read-only profile policy, but it is not an authorization substitute. The payment RPC continues to enforce owner role independently.

The live production database remains unchanged. These corrections are source-only and do not make the migrations ready for production without staging validation.


## Final fixed-email function inventory (read-only production snapshot)

The live inventory contains 25 SECURITY DEFINER functions with the legacy fixed-email body check. Two source migration groups cover 24: 12 operational/owner RPCs in `20261127_admin_rpc_role_migration.sql`, and 12 sensitive CRM/occupancy RPCs in `20261127_harden_remaining_admin_rpcs.sql`. The separate `confirm_public_booking(uuid)` endpoint is now also covered by a source-only owner-role patch: it replaces the fixed-email body check, pins `search_path=pg_catalog`, and grants EXECUTE only to authenticated. A tracked-repository caller scan found no direct caller; public creation uses `create_public_booking`, while the admin API uses `confirm_booking`/`cancel_booking`. External callers remain possible, so staging must test both flows. See `docs/security/20261127-public-booking-confirmation-caller-audit.md` and `docs/security/20261127-fixed-email-rpc-final-inventory.md`.

Read-only production check still returns NULL for `private.user_roles`, `private.has_admin_role()` and `private.has_owner_role()`. No production SQL or deployment has been performed.


## Legacy admin entrypoint consolidation (2026-11-27)

A complete branch-tree scan found legacy screens that were outside the current navigation but still contained direct table reads. To prevent old bookmarks or manually entered URLs from reopening those pages, the following source files now redirect to the canonical protected CRM screens: `admin.html`, `admin_payments.html`, `admin_v10_guest.html`, `admin_v10_guest_profile.html`, `admin_v12_guest_profile.html`, and `admin_bookings_v2.html`. Query strings are preserved for guest profiles and the booking workspace. The legacy-finance link was removed from the current finance page. Files were retained; nothing was deleted.

The canonical guest profile is `admin_guest_profile.html` + `guest_profile.js`, which calls `admin_get_guest_profile` and does not directly read tables. Ten static checks passed. These redirects are defense-in-depth only; the database remains the actual security boundary. See `docs/security/20261127-admin-legacy-entrypoint-consolidation.md`.


## Consolidated staging validation plan (2026-11-27)

The complete end-to-end execution order, actor matrix, data-integrity checks, rollback rehearsal and production go/no-go checklist are maintained in
`docs/security/20261127-staging-validation-plan.md`. Use that document as the operational test plan; this runbook remains the migration inventory and dependency rationale.

The staging plan adds explicit validation for two separate ordinary users (cross-user isolation), admin-versus-owner separation, service-role denial on interactive booking confirmation, public room/event field contracts, verified-contact account linking, payment/allocation idempotency and before/after financial invariants.

**Current release gate: NO-GO.** No staging project has been verified and no staging SQL/browser tests have been executed. The connected project remains production; no SQL, Edge Function deployment or production data change is authorized by this source-only preparation. A production rollout requires every staging gate and a separate explicit approval.
