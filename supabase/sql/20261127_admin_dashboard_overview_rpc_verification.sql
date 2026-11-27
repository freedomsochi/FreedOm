-- Read-only verification for admin_get_dashboard_overview().
select p.oid::regprocedure as function_signature,p.prosecdef as security_definer,
 p.proconfig as function_settings,
 has_function_privilege('anon',p.oid,'EXECUTE') as anon_can_execute,
 has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_can_execute,
 pg_get_functiondef(p.oid) like '%private.has_admin_role()%' as checks_admin_role,
 pg_get_functiondef(p.oid) like '%auth.uid() is null%' as rejects_null_identity,
 pg_get_functiondef(p.oid) like '%user_financial_summary%' as includes_finance_summary,
 pg_get_functiondef(p.oid) like '%limit 5%' as limits_upcoming_events,
 pg_get_functiondef(p.oid) like '%limit 6%' as limits_recent_registrations
from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and p.proname='admin_get_dashboard_overview'
 and pg_get_function_identity_arguments(p.oid)='';
