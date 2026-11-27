# Event registration payment RPC — authorization review

Date: 2026-11-27
Status: confirmed authorization gap; source-only review, no production changes.

## Function and database facts

Live catalog inspection of project `vutmbhsclmcfqqlzxqkc` found:

- Signature: `public.record_event_registration_payment(uuid, integer, text)`
- SECURITY DEFINER: yes
- EXECUTE: authenticated = yes; anon = no; PUBLIC = no
- Function body contains no `auth.uid()` or `auth.email()` authorization check.
- It selects a registration by caller-supplied ID, locks it, validates amount against remaining balance, creates a successful payment and allocation, then increments `paid_amount` and payment status.
- Therefore any signed-in account with a registration UUID may attempt to create a payment record against that registration. The function's financial checks prevent some invalid amounts but do not establish that the caller is authorized to perform the operation.

This is a confirmed missing authorization control in the function body, not evidence that exploitation has occurred.

## Confirmed application caller

Repository file `admin_v9_events.html` calls:

```js
db.rpc('record_event_registration_payment', {
  p_registration_id: id,
  p_amount: desired - currentPaid,
  p_payment_method: $('pm_'+id).value
})
```

The same page also directly updates event registration status and timestamps through the Supabase client. Its admin UI is not a security boundary. Any fix must preserve the intended event-management workflow for the approved privileged role.

## Proposed policy (review required)

Treat this as a financial mutation and initially require `owner` role via `private.has_owner_role()`, with explicit `auth.uid() IS NOT NULL` fail-closed behavior. Do not assume an ordinary event host should have payment-writing authority. If event operators need payment access, define a separate capability and audit scope before implementation.

## Required remediation package

1. Confirm owner-only policy or explicitly approve a narrower event-finance capability.
2. Add an authorization guard inside the SECURITY DEFINER function before reading or mutating registration/payment rows.
3. Keep the exact signature, default value, return type, business validations, row lock, payment allocation, and update semantics.
4. Review the function's schema-qualified references and safe fixed search_path; do not set `pg_catalog` only unless every dependency is qualified.
5. Keep authenticated EXECUTE only if the body guard is correct; otherwise revoke from authenticated and grant only to an approved backend role/caller.
6. Add tests for anon, ordinary authenticated user, event operator (if approved), admin, owner, missing UID, unknown role, duplicate/overpayment attempts, and concurrent payment attempts.
7. Provide an explicit forward repair and a rollback that restores the prior definition only in isolated staging; never automatically roll back to an authorization-vulnerable production state.
8. Reconcile existing event payments and allocations read-only; do not rewrite historic financial rows.

## Release boundary

No SQL was applied. No role was assigned. No live payment, registration, ACL, or function definition was changed. Production remediation requires a separately reviewed migration, staging evidence, and explicit release approval.
