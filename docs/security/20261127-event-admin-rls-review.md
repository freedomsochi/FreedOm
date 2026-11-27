# Event registration administration — RLS and caller review

Date: 2026-11-27. Read-only live catalog review; no changes applied.

## Browser caller behavior

`admin_v9_events.html` uses the publishable Supabase key and performs direct table operations:
- SELECT/INSERT/UPDATE on `public.events`;
- SELECT/UPDATE on `public.event_registrations`;
- calls `record_event_registration_payment(uuid,integer,text)` to create financial entries.

The page itself has no trustworthy admin authorization gate. Its JavaScript/UI cannot be treated as a security boundary. Database grants and RLS are the effective controls.

## Live RLS findings

All four inspected tables have RLS enabled:

| Table | Policy | Scope |
|---|---|---|
| events | admin_write_events | authenticated ALL; USING and WITH CHECK compare auth.email() to fixed owner email |
| events | public_read_events | anon + authenticated SELECT |
| event_registrations | admin_all_event_registrations | authenticated ALL; USING and WITH CHECK compare auth.email() to fixed owner email |
| payments | admin_all_payments | authenticated ALL; USING and WITH CHECK compare auth.email() to fixed owner email |
| payments | payments_admin_select | authenticated SELECT; same fixed email |
| payments | payments_insert_admin | authenticated INSERT; same fixed email |
| payment_allocations | payment_allocations_insert_admin | authenticated INSERT; same fixed email |
| payment_allocations | payment_allocations_select_admin | authenticated SELECT; same fixed email |

The policies currently prevent ordinary authenticated users from directly editing these tables, but they depend on the same hard-coded email identity that the role migration is intended to replace. They must be migrated in a coordinated release with the RPC authorization model. Do not change only the RPC and leave incompatible RLS policy assumptions without staging tests.

## Source-only remediation prepared

`supabase/sql/20261127_secure_event_registration_payment_rpc.sql` adds an owner-only guard inside the SECURITY DEFINER payment RPC before it reads or mutates any registration/payment rows. It preserves the signature, default, return type, row lock, amount validation, payment insertion, allocation insertion, and paid_amount/status update.

The migration is guarded by preconditions and postconditions:
- function exists with expected search_path and recognizable accounting body;
- role helper exists and has the same owner as the target RPC;
- no anon EXECUTE;
- authenticated EXECUTE remains unchanged;
- owner guard is present after replacement.

It does not change table RLS policies, assign any role, or alter historical payments.

## Release requirements still outstanding

1. Review and migrate the four RLS policy groups to the approved role helper in the same staged authorization release.
2. Test direct table SELECT/INSERT/UPDATE from anon, ordinary authenticated, admin, and owner sessions.
3. Test the payment RPC with null UID, ordinary user, admin, owner, invalid amount, overpayment, fully paid registration, missing registration, and concurrent requests.
4. Confirm the event admin page remains usable for the authorized owner; if event operators need event-only edit access, define a separate capability instead of granting financial owner rights.
5. Run Security Advisor after staging changes and inspect all remaining public SECURITY DEFINER endpoints.

No production SQL was run. No ACL, policy, payment, or registration data was changed.
