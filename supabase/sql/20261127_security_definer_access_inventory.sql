-- Read-only inventory of public SECURITY DEFINER functions.
-- Run against a controlled environment to track remaining hardening work.
select
  p.oid::regprocedure as signature,
  pg_get_function_result(p.oid) as result_type,
  coalesce(p.proconfig::text,'{}') as function_config,
  has_function_privilege('anon',p.oid,'execute') as anon_execute,
  has_function_privilege('authenticated',p.oid,'execute') as authenticated_execute,
  case
    when pg_get_functiondef(p.oid) like '%auth.email() <> ''serzh.xz@mail.ru''%' then 'nullable_email_guard'
    when pg_get_functiondef(p.oid) like '%auth.email() is distinct from%' then 'null_safe_email_guard'
    when pg_get_functiondef(p.oid) like '%v_email is null%' then 'explicit_null_email_guard'
    when pg_get_functiondef(p.oid) like '%auth.uid() is not null%' then 'uid_and_email_predicate'
    when pg_get_functiondef(p.oid) like '%auth.uid() is null%' then 'uid_null_guard'
    else 'manual_review'
  end as authorization_pattern
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and p.prosecdef
order by p.proname,p.oid::regprocedure::text;

-- Views carrying financial aggregates: security_invoker is required here.
select c.oid::regclass as view_name,c.reloptions,c.relacl,
       pg_get_viewdef(c.oid,true) as view_definition
from pg_class c
join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relkind='v'
  and c.relname in ('user_financial_summary','user_financial_breakdown')
order by c.relname;

-- Sensitive table RLS policies. This intentionally reports policy predicates
-- instead of changing them: do not split or revoke table grants before call-graph review.
select schemaname,tablename,policyname,roles,cmd,qual,with_check
from pg_policies
where schemaname='public'
  and tablename in ('users','bookings','orders','service_orders',
                    'event_registrations','payments','payment_allocations')
order by tablename,policyname;
