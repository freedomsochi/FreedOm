-- Manual rollback for admin_get_events_dashboard().
revoke all on function public.admin_get_events_dashboard() from public, anon, authenticated;
drop function if exists public.admin_get_events_dashboard();
