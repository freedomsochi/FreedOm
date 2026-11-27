select
  c.oid::regclass as view_name,
  coalesce(c.reloptions @> array['security_invoker=true'],false) as security_invoker,
  has_table_privilege('anon',c.oid,'select') as anon_select,
  has_table_privilege('authenticated',c.oid,'select') as authenticated_select,
  has_table_privilege('service_role',c.oid,'select') as service_role_select
from pg_catalog.pg_class c
join pg_catalog.pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relname='user_financial_summary' and c.relkind='v';
