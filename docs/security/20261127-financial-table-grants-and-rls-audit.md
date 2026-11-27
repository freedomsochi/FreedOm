# Financial table grants and RLS audit

Status: read-only production inventory, 2026-11-27. No database changes applied.

## Scope

Inspected the live grants, RLS flags, policies and view definitions for:
`payments`, `payment_allocations`, `user_financial_summary`,
`user_financial_breakdown`, `bookings`, `orders`, `service_orders`,
`event_registrations`, and `users`.

## Findings

### RLS and policies

All seven base tables in scope have RLS enabled. Both financial views are
`security_invoker=true`.

The following policies were found:

- `bookings.admin_all_bookings`: authenticated ALL, fixed email predicate.
- `orders.admin_all_orders`: authenticated ALL, fixed email predicate.
- `event_registrations.admin_all_event_registrations`: authenticated ALL,
  fixed email predicate.
- `payments.admin_all_payments`, `payments.payments_admin_select`, and
  `payments.payments_insert_admin`: authenticated policies, fixed email
  predicate. The SELECT and INSERT policies overlap with the ALL policy.
- `payment_allocations.payment_allocations_insert_admin` and
  `payment_allocations.payment_allocations_select_admin`: authenticated,
  fixed email predicate.
- `service_orders.admin_all_service_orders`,
  `service_orders.service_orders_admin_insert`, and
  `service_orders.service_orders_admin_select`: authenticated policies,
  fixed email predicate; SELECT and INSERT overlap with ALL.
- `users.admin_all_users`: authenticated ALL, fixed email predicate.

No anon policy appeared for these tables in the live `pg_policies` inventory.
Therefore anon table grants alone do not establish readable/writable rows under
the current RLS policy set; they are nevertheless unnecessary privilege surface.

### Direct table grants

The information_schema grant inventory reports anon and authenticated direct
privileges beyond the application’s apparent needs:

- `payments`, `payment_allocations`, `orders`, `service_orders`, and
  `event_registrations`: anon and authenticated have DELETE, INSERT, SELECT,
  UPDATE, REFERENCES, TRIGGER and TRUNCATE grants.
- `bookings` and `users`: anon and authenticated have REFERENCES, TRIGGER
  and TRUNCATE grants; no SELECT/INSERT/UPDATE/DELETE grants appeared.
- `user_financial_summary`: anon and authenticated have broad table-like
  privileges including SELECT and DML grants; it is a security-invoker view.
- `user_financial_breakdown`: authenticated has broad table-like privileges
  including SELECT and DML grants; it is a security-invoker view. No anon
  grant appeared in the information_schema result.

RLS does not govern TRUNCATE, REFERENCES, or TRIGGER privileges. The grants
should be reduced, but not before confirming direct client callers and
legitimate service workflows.

### Financial views

Both views use `security_invoker=true`, so underlying table grants and RLS
remain relevant. `user_financial_summary` aggregates total charged, paid,
debt and payment status by user. `user_financial_breakdown` exposes individual
booking/order/service/event charge labels, amounts, paid/debt values and dates.

## Recommended remediation sequence

1. Complete a source-level caller inventory for direct access to each table and
   view, including browser JS, Edge Functions, admin dashboards and integrations.
2. Replace fixed-email RLS policies with role helpers only after the owner/admin
   policy split is explicitly approved. Conservative candidate: owner-only for
   payments, allocations, service orders, users and financial views; booking
   and order access requires an operational workflow decision; event
   registrations require a privacy review.
3. Revoke unnecessary anon/authenticated table privileges, especially
   TRUNCATE, TRIGGER, REFERENCES and direct DML where all writes are already
   mediated by RPCs. Preserve only proven application needs.
4. Test anon, authenticated non-admin, operational admin, owner and service_role
   independently against staging fixtures.
5. Re-run grants, policies, view options and advisors after rollout.

## Safety boundary

This report does not prove an anon data leak: the inspected base-table RLS
policies were authenticated-only and the financial views are security-invoker.
It does identify excessive direct grants and fixed-email policies that should
be reduced. No grants, policies, view definitions, or data were changed.


## Follow-up: browser compatibility and effective access (2026-11-27)

A second read-only check compared browser queries against live SELECT privileges
and the exact live RLS policy set. It identified compatibility gaps that are
separate from the excessive GRANT surface:

- `booking-sync.js` selects `rooms(id,name,price_per_night)`, but anon has no
  SELECT privilege on `rooms`; the only listed policy is authenticated
  `admin_all_rooms`. The public booking room-resolution step therefore cannot
  rely on this direct query. `get_public_rooms()` is too narrow for a drop-in
  replacement because it does not return `price_per_night`; a new minimal
  server-side resolver/projection is needed.
- `rooms-catalog.js` calls `get_rooms_catalog()`, which is SECURITY INVOKER.
  Although anon/authenticated can execute the function, they cannot SELECT
  `rooms`; the function's underlying read is incompatible. A source-only
  replacement is already prepared separately.
- `profile.html` selects `users.*`, but authenticated currently has no SELECT
  privilege on `users`; only fixed-email `admin_all_users` is listed.
  Restore self-profile access through a minimal projection or a carefully
  scoped self-row policy after confirming the Auth-to-users identity mapping.
- `purchases.html` selects `orders.*` by current user_id. Authenticated has
  table SELECT, but the only listed RLS policy is fixed-email
  `admin_all_orders`; normal users therefore have no own-order row access.
- `admin_v10_finance.html` calls the finance overview RPC and then directly
  selects guest name/phone/email from `users`; the latter has no authenticated
  SELECT privilege in the current snapshot.
- `admin_v11_finance_detail.html`, `admin_v11_services.html`, and
  `admin_v10_events.html` depend on direct admin table reads protected by
  fixed-email policies. Converting only RPC guards to roles is insufficient:
  the corresponding RLS policies must be migrated in coordination, or the
  dashboards will lose access for role-based admins.

The live policy inventory shows no anon policy on event registrations,
payments, payment allocations, orders, service orders, users or bookings.
Their anon SELECT GRANTs (where present) do not by themselves prove anon row
exposure. Events is the exception: it has an explicit anon/authenticated
SELECT policy with `USING (true)`, which is why the separate public-event
visibility migration is important.

These findings require a caller-compatible access redesign before any table
GRANT revocation. They do not authorize broad public SELECT or production
policy changes.
