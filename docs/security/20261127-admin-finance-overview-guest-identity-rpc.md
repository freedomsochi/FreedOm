# Finance overview guest identity RPC

## Purpose
The finance overview already returns totals and charge breakdowns through
`admin_get_finance_overview()`, but the browser separately queried
`public.users` for display name, phone and email. This patch folds only those
three display fields and `user_id` into the existing protected response.

## Authorization
- Requires authenticated `auth.uid()` and `private.has_owner_role()`.
- SECURITY DEFINER with fixed `search_path=pg_catalog`; relations are schema-qualified.
- EXECUTE is revoked from PUBLIC and anon and granted to authenticated.
- Guest identities are limited to users represented in the finance summary.
- No new write access or financial mutation is introduced.

## Frontend
`admin_v10_finance.html` now consumes `data.users` from the RPC and no longer
queries `public.users` directly. Search, guest profile links and debt filtering
remain client-side.

## Release gates
1. Apply role foundation in isolated staging and assign approved test roles.
2. Apply the migration and run the verification query.
3. Test anon/ordinary authenticated denial and owner access only.
4. Compare finance totals and breakdowns before/after; verify users without a
   summary row are not included and guests with a summary row retain name/phone/email.
5. Confirm the page has no direct browser read from `public.users`.
6. Release only after staging passes and explicit approval.

## Rollback

The matching rollback SQL restores the exact pre-migration function definition captured from the live database on 2026-11-27, including its legacy fixed-email guard and prior grants. It is for emergency staging rollback only; do not use it to reintroduce the legacy guard as a production target.

No production SQL or deployment was performed.
