-- Manual rollback only; removes self-service SELECT policies and the profile column grant.
begin;
drop policy if exists users_select_own_profile on public.users;
drop policy if exists orders_select_own on public.orders;
drop policy if exists purchases_select_own on public.purchases;
drop policy if exists referrals_select_own_as_referrer on public.referrals;
revoke select (
  user_id, "Email", "Display_name", "Phone", "City", "Birth_date",
  "Ref_code", balance, "Created_at"
) on public.users from authenticated;
commit;
