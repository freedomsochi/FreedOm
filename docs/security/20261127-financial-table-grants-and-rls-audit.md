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
