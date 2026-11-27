-- Read-only verification after 20261127_harden_remaining_admin_rpcs.sql
-- and 20261127_admin_guest_booking_rpc_role_hardening.sql.
select p.oid::regprocedure as signature,p.prosecdef,p.proconfig,
       p.prosrc ilike '%private.has_owner_role()%' as owner_role_guard,
       p.prosrc ilike '%to_jsonb(u)%' as serializes_full_user_row,
       p.prosrc ilike '%can_record_payments%' as returns_owner_payment_capability,
       has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
       has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute
from pg_proc p
where p.oid='public.admin_get_guest_profile(uuid)'::regprocedure;

select
  position('jsonb_build_object(''user_id''' in pg_get_functiondef('public.admin_get_guest_profile(uuid)'::regprocedure))>0 as minimal_user_projection,
  position('can_record_payments' in pg_get_functiondef('public.admin_get_guest_profile(uuid)'::regprocedure))>0 as owner_payment_capability_returned;
