-- Read-only verification for 20261127_secure_event_registration_payment_rpc.sql.
-- Run only in isolated staging after the migration; this script performs no writes.

with target as (
  select p.oid, p.prosrc, p.proconfig, p.prosecdef, p.proowner, p.proacl
  from pg_proc p
  where p.oid = to_regprocedure('public.record_event_registration_payment(uuid,integer,text)')
),
helper as (
  select p.oid, p.proowner
  from pg_proc p
  where p.oid = to_regprocedure('private.has_owner_role()')
)
select
  (select count(*) from target) = 1 as target_exists,
  (select prosecdef from target) as security_definer,
  (select proconfig @> array['search_path=public'] from target) as expected_search_path,
  (select proowner from target) = (select proowner from helper) as helper_owner_matches,
  (select pg_get_functiondef(oid) like '%auth.uid() is null or not private.has_owner_role()%' from target) as owner_guard_present,
  has_function_privilege('anon',
    'public.record_event_registration_payment(uuid,integer,text)'::regprocedure,
    'EXECUTE') as anon_execute_must_be_false,
  has_function_privilege('authenticated',
    'public.record_event_registration_payment(uuid,integer,text)'::regprocedure,
    'EXECUTE') as authenticated_execute_preserved,
  (select pg_get_functiondef(oid) like '%INSERT INTO public.payment_allocations%' from target) as allocation_logic_present,
  (select pg_get_functiondef(oid) like '%FOR UPDATE%' from target) as row_lock_present;
