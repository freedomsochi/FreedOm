# Authenticated self-service reads — 2026-11-27

## Scope
This source-only patch restores the reads used by `profile.html` and `purchases.html` without introducing SECURITY DEFINER RPCs.

Live read-only inspection confirmed:
- `users.user_id`, `orders.user_id`, and `purchases.Buyer_id` are UUIDs; the profile page already filters `users.user_id` by the Supabase Auth user UUID.
- `orders`, `purchases`, `referrals`, and `users` have RLS enabled.
- `users` had no authenticated SELECT grant; its only SELECT policy was the fixed-email admin policy.
- `orders` and `purchases` had authenticated SELECT grants but only fixed-email admin SELECT policies.
- `referrals` had an authenticated SELECT grant but only an admin SELECT policy.

## Changes
- Adds owner-scoped SELECT policies: `users.user_id = auth.uid()`, `orders.user_id = auth.uid()`, `purchases.Buyer_id = auth.uid()`, and `referrals.Referrer_id = auth.uid()`.
- Grants authenticated users SELECT only on the profile fields rendered by `profile.html` plus `Email`, which the admin finance overview uses to identify guests.
- Keeps existing admin policies intact; PostgreSQL combines permissive policies with OR.
- Changes both pages to request explicit columns rather than `*`.

## Release gates
1. Apply migration only to a staging database after verifying the schema matches.
2. Test two distinct authenticated accounts: each sees only its own profile, kitchen orders, purchases, and referral rows; neither can read the other's records.
3. Confirm the admin account still sees the expected rows through its existing admin policies.
4. Confirm anonymous requests see no rows.
5. Run the verification SQL and Supabase security advisors.
6. Only then consider production rollout and frontend deployment together.

No production SQL was executed and no deployment was performed.
