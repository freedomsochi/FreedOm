# Admin RPC guard hardening — 2026-11-27

Prepared a catalog-preserving migration for:
- `record_user_payment_for_charge(uuid,text,uuid,integer,text,text)`
- `add_service_order(uuid,uuid,integer,text)`
- `create_manual_guest(text,text,text,text,date,text)`

The migration reads each current function definition with `pg_get_functiondef`, replaces only the exact legacy email predicate with a non-null UID plus null-safe `IS DISTINCT FROM` check, and aborts if the expected old guard is absent. It then pins `search_path=pg_catalog` and explicitly maintains authenticated/service_role execution while revoking PUBLIC/anon.

Files:
- `supabase/sql/20261127_harden_admin_rpc_guards.sql`
- `supabase/sql/20261127_harden_admin_rpc_guards_verification.sql`

Repository-only. Not run against production. This is an interim guard until the private role-table foundation and full admin-role migration are safely tested together.
