-- Read-only verification for admin_get_events_dashboard()
select
  p.oid::regprocedure as function_signature,
  p.prosecdef as security_definer,
  p.provolatile as volatility,
  p.proconfig as function_settings,
  has_function_privilege('anon', p.oid, 'EXECUTE') as anon_can_execute,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_can_execute,
  pg_get_functiondef(p.oid) like '%private.has_admin_role()%' as checks_admin_role,
  pg_get_functiondef(p.oid) like '%auth.uid() is null%' as rejects_null_identity
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and p.proname='admin_get_events_dashboard';

select count(*) as event_rows from public.events;
select count(*) as registration_rows from public.event_registrations;
