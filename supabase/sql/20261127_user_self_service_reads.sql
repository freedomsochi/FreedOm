-- Source-only migration. Apply to staging first; do not run on production without approval.
-- Restores authenticated self-service reads without widening cross-user visibility.

begin;

drop policy if exists users_select_own_profile on public.users;
create policy users_select_own_profile
  on public.users
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

grant select (
  user_id,
  "Display_name",
  "Phone",
  "City",
  "Birth_date",
  "Ref_code",
  balance,
  "Created_at"
) on public.users to authenticated;

drop policy if exists orders_select_own on public.orders;
create policy orders_select_own
  on public.orders
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists purchases_select_own on public.purchases;
create policy purchases_select_own
  on public.purchases
  for select
  to authenticated
  using ((select auth.uid()) = "Buyer_id");

drop policy if exists referrals_select_own_as_referrer on public.referrals;
create policy referrals_select_own_as_referrer
  on public.referrals
  for select
  to authenticated
  using ((select auth.uid()) = "Referrer_id");

commit;
