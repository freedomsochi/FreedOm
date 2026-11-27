# Finance RPC hardening — 2026-11-27

Prepared two additional source-only replacements:
- `record_payment(uuid, uuid, integer, text, text)`
- `record_user_payment(uuid, integer, text, text)`

Both previously used `auth.email() <> 'serzh.xz@mail.ru'`, which does not reject a NULL email claim. The replacements require both a non-null `auth.uid()` and a null-safe exact email match (`IS DISTINCT FROM`), pin `search_path=pg_catalog`, preserve the original payment/allocations workflow and row locks, and explicitly revoke PUBLIC/anon while preserving authenticated/service_role execution.

Files:
- `supabase/sql/20261127_harden_finance_payment_rpcs.sql`
- `supabase/sql/20261127_harden_finance_payment_rpcs_verification.sql`

This remains repository-only. Not applied to production; no payment records or balances were changed. Before rollout, validate admin and non-admin sessions, all four charge types, partial/full payment, allocation totals, and rollback in a safe environment.
