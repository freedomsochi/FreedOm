-- Read-only verification of the guest/bookings/payment admin RPC role follow-up.
select p.oid::regprocedure as signature,p.prosecdef,p.proconfig,
 has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
 has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute,
 p.prosrc ilike '%private.has_admin_role()%' as admin_role_guard,
 p.prosrc ilike '%private.has_owner_role()%' as owner_role_guard,
 p.prosrc ilike '%serzh.xz@mail.ru%' as legacy_email_guard,
 p.prosrc ilike '%to_jsonb(u)%' as serializes_full_user_row,
 p.prosrc ilike '%can_record_payments%' as returns_owner_payment_capability
from pg_proc p
where p.oid in (
 'public.admin_get_bookings_overview()'::regprocedure,
 'public.admin_get_guest_dashboard_stats()'::regprocedure,
 'public.admin_get_guest_profile(uuid)'::regprocedure,
 'public.admin_get_guests_overview()'::regprocedure,
 'public.admin_record_guest_payment(uuid,integer,text,text,uuid)'::regprocedure
)
order by p.proname;

select
 to_regprocedure('private.has_admin_role()') is not null as admin_helper_present,
 to_regprocedure('private.has_owner_role()') is not null as owner_helper_present;
