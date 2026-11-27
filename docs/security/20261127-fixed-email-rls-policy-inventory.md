# FreeDom — inventory of fixed-email RLS policies

Date: 2026-11-27
Branch: fix/security-rpc-hardening-2026-11-26

## Live read-only findings

A catalog query against the connected Supabase project found 24 RLS policies in 17 public tables whose USING or WITH CHECK expressions compare `auth.email()` to the fixed owner email. All 17 tables have RLS enabled.

The protected role foundation is not installed in the live database:
- `private.user_roles`: absent
- `private.has_admin_role()`: absent
- `private.has_owner_role()`: absent

No DDL, DML, grants, policies, role assignments, or production data were changed.

## Policy inventory and provisional role classification

This is a proposed least-privilege mapping for review, not an approved authorization policy.

| Table | Existing policy name(s) | Provisional scope | Reason / caveat |
|---|---|---|---|
| bookings | admin_all_bookings | admin, potentially owner-only for full guest PII | Booking operations require access, but guest contact data is sensitive; confirm operator access. |
| event_registrations | admin_all_event_registrations | admin for event operations; owner for payment fields if column-level separation is unavailable | Current ALL policy combines status and financial data. |
| events | admin_write_events | admin | Event content management. |
| orders | admin_all_orders | admin, with finance fields requiring review | Kitchen/order fulfillment; inspect columns before widening role access. |
| payment_allocations | payment_allocations_insert_admin; payment_allocations_select_admin | owner | Financial ledger allocation mutation/read. |
| payments | admin_all_payments; payments_admin_select; payments_insert_admin; payments_select_admin | owner | Financial ledger and payment PII. Duplicate SELECT policies should be reconciled, not blindly dropped. |
| purchases | admin_all_purchases | owner pending schema/caller review | Financial/purchase records; do not infer operational access. |
| referrals | referrals_admin_delete; referrals_admin_insert; referrals_admin_select; referrals_admin_update | owner pending business-rule review | Referral data may contain personal/commission information. |
| rooms | admin_all_rooms | admin | Room inventory and availability administration. |
| service_orders | admin_all_service_orders; service_orders_admin_insert; service_orders_admin_select | admin for fulfillment; owner if financial adjustments are embedded | Verify whether operators need create/update or only view. |
| services | services_admin_insert; services_admin_update | admin | Service catalogue maintenance. |
| transactions | admin_all_transactions | owner | Financial transaction ledger. |
| users | admin_all_users | owner | Identity/profile administration and personal data. |
| veg_raw_menu | admin_write_veg_raw_menu | admin | Menu content operations. |

## Why a one-shot rewrite is unsafe

1. Existing policies are not all equivalent: some are ALL, some are SELECT/INSERT/UPDATE/DELETE, and some duplicate SELECT access.
2. PostgreSQL RLS policies are permissive by default; adding a new role-based permissive policy without removing/replacing the old policy does not narrow access.
3. Event registrations mix status administration and payment totals in one table. A table-level admin policy cannot grant event status updates while excluding payment columns.
4. Several operational tables contain guest/customer PII. Role assignment must reflect the intended staff privacy boundary.
5. The role helper foundation is absent in live DB. Any policy referencing it would fail until the foundation is staged first.
6. Existing frontend pages make direct table requests; RPC-only role changes will not cover these direct reads/writes.

## Recommended staged sequence

1. Approve the provisional table-by-table admin/owner mapping and decide whether operational admins may see guest contact details.
2. Inspect table columns and every direct frontend caller for bookings, orders, event registrations, users, payments, purchases, referrals, transactions, service orders, and rooms.
3. Stage the protected role table/helpers with no default role assignment.
4. Replace the 24 fixed-email policies transactionally with explicit admin/owner predicates; preserve each command scope and WITH CHECK behavior.
5. Resolve duplicate policy names/semantics deliberately and add assertions that no fixed-email policy remains on the reviewed tables.
6. Run role matrix tests (anon, ordinary authenticated, admin, owner, NULL UID, unknown/missing role), plus direct browser workflow tests.
7. Only after staging evidence, prepare a production release plan and rollback. Do not assign roles or apply migrations in production without separate approval.

## Verification query

Use this query after staging migration to confirm the old fixed-email policy predicates are gone from public:
```sql
select n.nspname, c.relname, p.polname,
       pg_get_expr(p.polqual,p.polrelid) as using_expr,
       pg_get_expr(p.polwithcheck,p.polrelid) as check_expr
from pg_policy p
join pg_class c on c.oid=p.polrelid
join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public'
  and (
    coalesce(pg_get_expr(p.polqual,p.polrelid),'') ilike '%auth.email%'
    or coalesce(pg_get_expr(p.polwithcheck,p.polrelid),'') ilike '%auth.email%'
  )
order by c.relname,p.polname;
```

A zero-row result is only a predicate inventory check; it does not prove the replacement policies are correct. The role matrix and functional tests remain mandatory.
