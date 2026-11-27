-- Manual rollback for the new dashboard read endpoint.
revoke all on function public.admin_get_dashboard_overview() from public, anon, authenticated;
drop function if exists public.admin_get_dashboard_overview();
