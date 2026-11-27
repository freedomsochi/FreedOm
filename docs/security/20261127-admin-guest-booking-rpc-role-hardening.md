# Guest profile response minimization

## Prerequisite
Apply and verify `supabase/sql/20261127_harden_remaining_admin_rpcs.sql` in isolated staging first. That migration assigns owner-role authorization to guest, booking overview, financial and space-detail RPCs. This follow-up does not duplicate or alter those guards.

## Change
- The profile RPC returns only `user_id`, `Display_name`, `Phone`, `Email`, and `City` for the identity object instead of serializing every column in `public.users`.
- It adds `can_record_payments`, computed by `private.has_owner_role()`.
- `guest_profile.js` displays the payment form only when the capability is true. The profile itself is owner-only today; the capability flag is a defense-in-depth UI gate and allows a future read-only profile role without exposing the payment form.
- Owner-only payment mutation remains enforced inside `admin_record_guest_payment(...)`; hiding the form is a usability measure, not the security boundary.

## Staging tests
1. Apply the role foundation, assign a staging owner, and apply/verify the 12-RPC owner hardening migration.
2. Apply this response-minimization migration.
3. Verify guest identity fields render and no unrelated `users` columns are returned.
4. Test owner payment form visibility and payment mutation; test admin/non-owner denial at the RPC layer.
5. Run the rollback only if needed; it restores the former full-row projection but preserves the owner guard and fixed search path.

No production SQL or deployment was performed.
