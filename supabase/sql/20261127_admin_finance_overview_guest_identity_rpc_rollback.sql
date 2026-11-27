-- Manual rollback: restore the previous admin_get_finance_overview() definition
-- from the recorded pre-migration backup before removing the role-based endpoint.
-- Do not restore the fixed-email guard in production without a separately approved plan.
revoke all on function public.admin_get_finance_overview() from public, anon, authenticated;
