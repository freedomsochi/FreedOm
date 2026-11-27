-- Read-only verification for 20261127_user_self_service_reads.sql.
-- Checks RLS state, exact ownership predicates, and the intended SELECT grants.

with expected(table_name, policy_name, expected_column) as (
  values
    ('users','users_select_own_profile','user_id'),
    ('orders','orders_select_own','user_id'),
    ('purchases','purchases_select_own','Buyer_id'),
    ('referrals','referrals_select_own_as_referrer','Referrer_id')
),
actual as (
  select e.*, c.oid, c.relrowsecurity, p.cmd, p.roles, p.qual
    from expected e
    left join pg_class c
      on c.relnamespace='public'::regnamespace
     and c.relname=e.table_name
    left join pg_policies p
      on p.schemaname='public'
     and p.tablename=e.table_name
     and p.policyname=e.policy_name
)
select table_name,
       policy_name,
       oid is not null as table_found,
       coalesce(relrowsecurity,false) as rls_enabled,
       cmd,
       roles,
       qual,
       case
         when oid is null then 'FAIL_TABLE_MISSING'
         when not relrowsecurity then 'FAIL_RLS_DISABLED'
         when cmd is distinct from 'SELECT' then 'FAIL_POLICY_COMMAND'
         when not ('authenticated' = any(roles)) then 'FAIL_POLICY_ROLE'
         when 'public' = any(roles) then 'FAIL_POLICY_INCLUDES_PUBLIC'
         when qual is null
           or qual not ilike '%auth.uid()%'
           or qual not ilike '%' || expected_column || '%' then 'FAIL_OWNERSHIP_PREDICATE'
         else 'PASS_POLICY_STATIC_CHECKS'
       end as status
  from actual
 order by table_name;

-- Exact user profile columns granted to authenticated clients.
with expected(column_name) as (
  values
    ('user_id'),('Email'),('Display_name'),('Phone'),('City'),
    ('Birth_date'),('Ref_code'),('balance'),('Created_at')
),
actual as (
  select e.column_name,
         exists (
           select 1
             from information_schema.column_privileges cp
            where cp.table_schema='public'
              and cp.table_name='users'
              and cp.grantee='authenticated'
              and cp.column_name=e.column_name
              and cp.privilege_type='SELECT'
         ) as granted
    from expected e
)
select column_name, granted,
       case when granted then 'PASS_COLUMN_GRANT' else 'FAIL_COLUMN_GRANT' end as status
  from actual
 order by column_name;

-- Orders, purchases and referrals require table-level SELECT plus own-row RLS.
select table_name,
       has_table_privilege('authenticated','public.'||table_name,'SELECT') as authenticated_select,
       has_table_privilege('anon','public.'||table_name,'SELECT') as anon_select
from (values ('orders'),('purchases'),('referrals')) t(table_name)
order by table_name;

-- A table-level users SELECT grant would bypass the intended column allowlist.
select
  has_table_privilege('authenticated','public.users','SELECT') as authenticated_table_select,
  has_table_privilege('anon','public.users','SELECT') as anon_table_select;

-- Review all matching policies, including unexpected duplicates that may widen access.
select tablename,policyname,cmd,roles,qual,with_check
from pg_policies
where schemaname='public'
  and tablename in ('users','orders','purchases','referrals')
order by tablename,policyname;
