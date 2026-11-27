# Financial summary view: remove anonymous access grant

Date: 2026-11-27  
Branch: `fix/security-rpc-hardening-2026-11-26`  
Status: source-only patch; not applied to Supabase production.

## Finding

The live `public.user_financial_summary` view is configured with `security_invoker=true`, but its ACL explicitly grants `anon` broad view privileges. The view aggregates per-user charged, paid, debt and payment status from `users` and `user_financial_breakdown`.

The underlying source tables are protected by RLS and/or lack anonymous SELECT grants, so this finding does **not** establish that anonymous users can currently read the financial data. It is nevertheless an unnecessary anonymous API grant on a sensitive financial view and violates least privilege.

## Patch

`supabase/sql/20261127_revoke_anon_financial_summary_view.sql` checks that the expected security-invoker view exists, then revokes all privileges from `anon`. It does not alter the view definition, authenticated/service_role access, underlying table grants, or RLS policies.

## Verification

Run `supabase/sql/20261127_revoke_anon_financial_summary_view_verification.sql` in staging. Expected: one row, `security_invoker=true`, `anon_select=false`, and authenticated/service_role SELECT remain true.

## Compatibility

Before production rollout, confirm no public website route intentionally queries this admin-only finance summary view. Admin dashboards should continue to work using authenticated access. No production change has been made.
