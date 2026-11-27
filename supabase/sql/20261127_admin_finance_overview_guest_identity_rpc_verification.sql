-- Read-only verification for admin_get_finance_overview().
select
  p.oid::regprocedure as function_signature,
  p.prosecdef as security_definer,
  p.proconfig as function_settings,
  has_function_privilege('anon',p.oid,'EXECUTE') as anon_can_execute,
  has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_can_execute,
  pg_get_functiondef(p.oid) like '%private.has_admin_role()%' as checks_admin_role,
  pg_get_functiondef(p.oid) like '%auth.uid() is null%' as rejects_null_identity,
  pg_get_functiondef(p.oid) like '%v_users%' as returns_guest_identity,
  pg_get_functiondef(p.oid) like '%user_financial_breakdown%' as includes_finance_breakdown
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and p.proname='admin_get_finance_overview'
  and pg_get_function_identity_arguments(p.oid)='';

select
  to_regprocedure('private.has_admin_role()') is not null as role_foundation_present,
  to_regprocedure('public.admin_get_finance_overview()') is not null as finance_overview_present;
