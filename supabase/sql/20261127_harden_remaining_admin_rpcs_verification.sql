-- READ ONLY verification for 20261127_harden_remaining_admin_rpcs.sql
-- Run only after applying it to an isolated staging database.

with expected(signature) as (
  values
    ('admin_get_bookings_overview()'),
    ('admin_get_finance_overview()'),
    ('admin_get_guest_dashboard_stats()'),
    ('admin_get_guest_profile(uuid)'),
    ('admin_get_guests_overview()'),
    ('admin_get_rooms()'),
    ('admin_get_space_location(text)'),
    ('admin_get_space_navigation()'),
    ('admin_get_space_overview()'),
    ('admin_get_user_debts()'),
    ('admin_get_users()'),
    ('admin_record_guest_payment(uuid,integer,text,text,uuid)')
),
actual as (
  select e.signature, p.oid, p.prosrc, p.prosecdef, p.proconfig,
         case when p.oid is null then null else has_function_privilege('anon',p.oid,'EXECUTE') end anon_execute,
         case when p.oid is null then null else has_function_privilege('authenticated',p.oid,'EXECUTE') end authenticated_execute
  from expected e
  left join pg_proc p
    on p.pronamespace='public'::regnamespace
   and p.oid=to_regprocedure('public.'||e.signature)
)
select signature,
       oid is not null as function_found,
       coalesce(prosecdef,false) as security_definer,
       coalesce(prosrc ilike '%private.has_owner_role()%',false) as owner_guard_present,
       coalesce(array_to_string(proconfig,','),'') as function_settings,
       anon_execute,
       authenticated_execute,
       case
         when oid is null then 'FAIL_MISSING'
         when not prosecdef then 'FAIL_NOT_SECURITY_DEFINER'
         when prosrc not ilike '%private.has_owner_role()%' then 'FAIL_OWNER_GUARD'
         when coalesce(array_to_string(proconfig,','),'') not like '%search_path=pg_catalog%' then 'FAIL_SEARCH_PATH'
         when coalesce(anon_execute,true) then 'REVIEW_ANON_EXECUTE'
         when not coalesce(authenticated_execute,false) then 'REVIEW_AUTHENTICATED_EXECUTE'
         else 'PASS_STATIC_CHECKS'
       end as status
from actual
order by signature;

-- Helper must be protected and use a fixed path.
select p.oid::regprocedure as helper_signature,
       p.prosecdef as security_definer,
       p.provolatile='s' as stable,
       p.proconfig,
       has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
       has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute
from pg_proc p
where p.oid='private.has_owner_role()'::regprocedure;
