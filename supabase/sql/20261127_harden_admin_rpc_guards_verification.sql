select p.oid::regprocedure::text signature,p.proconfig,
 has_function_privilege('anon',p.oid,'EXECUTE') anon_execute,
 has_function_privilege('authenticated',p.oid,'EXECUTE') authenticated_execute,
 has_function_privilege('service_role',p.oid,'EXECUTE') service_role_execute,
 position('auth.uid() is null' in lower(p.prosrc))>0 requires_uid,
 position('auth.email() is distinct from' in lower(p.prosrc))>0 null_safe_admin_guard
from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and p.proname in
('record_user_payment_for_charge','add_service_order','create_manual_guest')
order by 1;