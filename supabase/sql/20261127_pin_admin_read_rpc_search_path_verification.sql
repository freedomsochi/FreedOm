-- Expected: exactly 12 rows, all SECURITY DEFINER with pinned path.
select p.oid::regprocedure as signature,
       p.prosecdef as security_definer,
       coalesce(p.proconfig @> array['search_path=pg_catalog, public'],false) as search_path_pinned,
       has_function_privilege('anon',p.oid,'execute') as anon_execute,
       has_function_privilege('authenticated',p.oid,'execute') as authenticated_execute
from pg_proc p
where p.oid in (
  to_regprocedure('public.admin_get_bookings_overview()'),
  to_regprocedure('public.admin_get_finance_overview()'),
  to_regprocedure('public.admin_get_guest_dashboard_stats()'),
  to_regprocedure('public.admin_get_guest_profile(uuid)'),
  to_regprocedure('public.admin_get_guests_overview()'),
  to_regprocedure('public.admin_get_rooms()'),
  to_regprocedure('public.admin_get_space_location(text)'),
  to_regprocedure('public.admin_get_space_navigation()'),
  to_regprocedure('public.admin_get_space_overview()'),
  to_regprocedure('public.admin_get_user_debts()'),
  to_regprocedure('public.admin_get_users()'),
  to_regprocedure('public.admin_record_guest_payment(uuid,integer,text,text,uuid)')
)
order by 1;
