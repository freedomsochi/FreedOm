-- Read-only verification for 20261127_user_self_service_reads.sql
select
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  exists (
    select 1 from pg_policies p
    where p.schemaname='public'
      and p.tablename=c.relname
      and p.policyname in (
        'users_select_own_profile',
        'orders_select_own',
        'purchases_select_own',
        'referrals_select_own_as_referrer'
      )
  ) as own_read_policy_present
from pg_class c
join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public'
  and c.relname in ('users','orders','purchases','referrals')
order by c.relname;

select grantee,table_name,column_name,privilege_type
from information_schema.column_privileges
where table_schema='public'
  and table_name='users'
  and grantee='authenticated'
  and column_name in (
    'user_id','Display_name','Phone','City','Birth_date',
    'Ref_code','balance','Created_at'
  )
order by column_name;

select tablename,policyname,cmd,roles,qual
from pg_policies
where schemaname='public'
  and policyname in (
    'users_select_own_profile',
    'orders_select_own',
    'purchases_select_own',
    'referrals_select_own_as_referrer'
  )
order by tablename;
