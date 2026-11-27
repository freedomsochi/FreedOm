select
  p.oid::regprocedure::text as signature,
  p.prosecdef as security_definer,
  p.proconfig as function_config,
  has_function_privilege('anon', p.oid, 'EXECUTE') as anon_execute,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_execute,
  has_function_privilege('service_role', p.oid, 'EXECUTE') as service_role_execute,
  position('auth.uid() is null' in lower(p.prosrc)) > 0 as rejects_missing_uid,
  position('auth.email() is distinct from' in lower(p.prosrc)) > 0 as null_safe_admin_check,
  position('for update' in lower(p.prosrc)) > 0 as locks_registration,
  position('payment_allocations' in lower(p.prosrc)) > 0 as writes_allocation
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname = 'record_event_registration_payment'
  and pg_get_function_identity_arguments(p.oid) =
      'p_registration_id uuid, p_amount integer, p_payment_method text';
-- Expected after controlled application: anon=false, authenticated=true,
-- service_role=true, missing-uid rejection=true, null-safe guard=true,
-- search_path=pg_catalog, row lock=true, allocation write=true.
