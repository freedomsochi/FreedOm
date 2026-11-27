select p.oid::regprocedure::text signature,p.proconfig,
 has_function_privilege('anon',p.oid,'EXECUTE') anon_execute,
 has_function_privilege('authenticated',p.oid,'EXECUTE') authenticated_execute,
 has_function_privilege('service_role',p.oid,'EXECUTE') service_role_execute,
 position('auth.uid() is null' in lower(p.prosrc))>0 requires_uid,
 position('auth.email() is distinct from' in lower(p.prosrc))>0 null_safe_admin_guard,
 position('search_path=pg_catalog' in coalesce(array_to_string(p.proconfig,','),''))>0 pinned_search_path
from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and p.proname in ('record_payment','record_user_payment')
order by 1;