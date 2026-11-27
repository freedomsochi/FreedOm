-- READ ONLY verification for public events RLS.
-- Run after the companion SQL patch in staging.

do $verify$
declare
  v_qual text;
begin
  select qual into v_qual
    from pg_policies
   where schemaname='public'
     and tablename='events'
     and policyname='public_read_events'
     and cmd='SELECT';

  if v_qual is null then
    raise exception 'public_read_events SELECT policy is missing';
  end if;

  if v_qual not ilike '%is_active%' or v_qual not ilike '%show_on_home%' then
    raise exception 'Public event policy does not restrict both visibility flags';
  end if;

  if not exists (
    select 1 from pg_policies
     where schemaname='public'
       and tablename='events'
       and policyname='admin_write_events'
       and cmd='ALL'
  ) then
    raise exception 'Existing admin write policy was unexpectedly changed';
  end if;

  if (select proconfig from pg_proc where oid=to_regprocedure('public.get_home_events(integer)')) is distinct from array['search_path=pg_catalog']::text[] then
    raise exception 'get_home_events search_path is not pinned to pg_catalog';
  end if;

  if has_function_privilege('anon','public.get_home_events(integer)','EXECUTE') is not true
     or has_function_privilege('authenticated','public.get_home_events(integer)','EXECUTE') is not true then
    raise exception 'Public homepage event RPC grants were not preserved';
  end if;

  if exists (
    select 1 from aclexplode(coalesce((select proacl from pg_proc where oid=to_regprocedure('public.get_home_events(integer)')),acldefault('f',(select proowner from pg_proc where oid=to_regprocedure('public.get_home_events(integer)'))))) a
    where a.grantee=0 and a.privilege_type='EXECUTE'
  ) then
    raise exception 'get_home_events still has implicit PUBLIC EXECUTE';
  end if;
end
$verify$;

select schemaname,tablename,policyname,roles,cmd,qual,with_check
from pg_policies
where schemaname='public' and tablename='events'
order by policyname;

-- Staging tests with disposable event rows:
-- 1. anon SELECT returns active + show_on_home rows only.
-- 2. anon cannot see inactive or show_on_home=false rows.
-- 3. authorized admin retains intended administrative access.
-- 4. public get_home_events() still returns only active/homepage-visible future rows.
