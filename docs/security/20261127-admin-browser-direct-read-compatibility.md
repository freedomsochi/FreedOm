# Admin browser data-access compatibility map — 2026-11-27

This document records the live browser callers inspected on the working branch. It is a source/release map, not an authorization change.

## Direct browser reads

| Page | Direct reads | Current purpose | Required release condition |
|---|---|---|---|
| `admin_v10_finance.html` | `admin_get_finance_overview()` RPC | Uses a minimal guest identity projection included in the finance summary response | Role foundation and updated role-checked RPC must be staged before release; no direct `users` SELECT remains. |
| `admin_v11_finance_detail.html` | `admin_get_finance_charge_detail(type,id)` RPC | Loads one charge and its successful allocation history | Role foundation and role-checked RPC must be staged; payment mutation remains separately owner-gated. URL `user_id` is not an authorization input. |
| `admin_v11_services.html` | `admin_get_services_dashboard()` RPC | Lists projected service rows and totals successful allocations | Role foundation must exist; RPC requires owner role and counts only successful payments. |
| `admin_v10_events.html` | `admin_get_events_dashboard()` RPC | Lists projected event rows and participant contact/registration details | Role foundation must exist; RPC requires owner role. |

## Implementation update (2026-11-27)\n\n- `admin_v10_events.html` no longer reads `events` or `event_registrations` directly; it uses `admin_get_events_dashboard()`.\n- `admin_v11_services.html` no longer reads `service_orders` or `payment_allocations` directly; it uses `admin_get_services_dashboard()`.\n- Both RPCs have source-only SQL, verification, rollback, and release notes. Both depend on `private.has_admin_role()` from the role foundation.\n- Read-only production inspection confirms `private.has_admin_role()`, `private.has_owner_role()`, and both new RPCs are currently absent. The migrations are therefore not deployable to production as-is.\n\n## Findings and cautions

- The admin pages currently use direct table reads rather than a single RPC boundary.
- Fixed-email policies currently provide the row-level admin gate for several of these tables. The role migration must not be considered complete until these table policies are migrated in the same release.
- `admin_v11_finance_detail.html` reads a row using both charge ID and query-string `user_id`. A malicious user can change either URL parameter; RLS/admin authorization must deny access regardless.
- `admin_v10_finance.html` uses a narrow explicit projection already. Its `Email` column dependency is included in `20261127_user_self_service_reads.sql` because the page also needs that field for the admin-only view.
- `admin_v10_events.html` currently reads `events.select('*')`; public SELECT on `events` therefore exposes all columns of rows admitted by the public policy. Row filtering alone is not a column-level projection. Consider replacing this with a dedicated public/admin event projection before widening any event grants.
- No browser caller was changed in this document. No production database changes or deployment were performed.

## Next implementation sequence

1. Replace event admin broad reads with an admin RPC returning only the fields used by the page.
2. Replace finance-detail multi-table direct reads with one charge-detail RPC that validates the admin role and accepts a constrained charge type/ID.
3. Replace service listing direct reads with an admin RPC returning service rows and successful allocation totals.
4. Migrate the fixed-email table policies to the role model only after all page callers and RPC authorization are verified.
5. Stage-test with anonymous, ordinary authenticated, admin, and owner accounts before production rollout.


## Finance read-path update (2026-11-27)

- `admin_v10_finance.html` now reads guest identity fields from `admin_get_finance_overview()`; the browser-side `users` query has been removed. The RPC migration is source-only and replaces the live fixed-email guard with `private.has_admin_role()`.
- `admin_v11_finance_detail.html` now calls `admin_get_finance_charge_detail(text,uuid)`; direct reads from the five finance charge/allocation tables and payments have been removed from the page.
- Both RPCs use explicit projections, `auth.uid()` plus the protected role helper, fixed `search_path=pg_catalog`, and authenticated-only EXECUTE.
- Static checks passed. Production still lacks the role foundation and finance detail RPC. Do not deploy either updated finance page before staging tests and coordinated approval.
