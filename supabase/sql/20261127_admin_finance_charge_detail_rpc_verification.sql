-- Read-only verification for admin_get_finance_charge_detail(text,uuid).
select
  p.oid::regprocedure as function_signature,
  p.prosecdef as security_definer,
  p.provolatile as volatility,
  p.proconfig as function_settings,
  has_function_privilege('anon',p.oid,'EXECUTE') as anon_can_execute,
  has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_can_execute,
  pg_get_functiondef(p.oid) like '%private.has_admin_role()%' as checks_admin_role,
  pg_get_functiondef(p.oid) like '%auth.uid() is null%' as rejects_null_identity,
  pg_get_functiondef(p.oid) like '%p.status=''успешно''%' as filters_successful_payments
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and p.proname='admin_get_finance_charge_detail'
  and pg_get_function_identity_arguments(p.oid)='p_charge_type text, p_charge_id uuid';

select
  to_regprocedure('private.has_admin_role()') is not null as role_foundation_present,
  to_regprocedure('public.admin_get_finance_charge_detail(text,uuid)') is not null as rpc_present;
