-- Pin search_path for existing authenticated admin SECURITY DEFINER RPCs.
-- Source-only: run in staging first; do not apply to production without approval.
do $$
declare
  v_sig text;
  v_oid oid;
  v_targets text[] := array[
    'public.admin_get_bookings_overview()',
    'public.admin_get_finance_overview()',
    'public.admin_get_guest_dashboard_stats()',
    'public.admin_get_guest_profile(uuid)',
    'public.admin_get_guests_overview()',
    'public.admin_get_rooms()',
    'public.admin_get_space_location(text)',
    'public.admin_get_space_navigation()',
    'public.admin_get_space_overview()',
    'public.admin_get_user_debts()',
    'public.admin_get_users()',
    'public.admin_record_guest_payment(uuid,integer,text,text,uuid)'
  ];
begin
  foreach v_sig in array v_targets loop
    v_oid := pg_catalog.to_regprocedure(v_sig);
    if v_oid is null then
      raise exception 'Required admin function missing: %', v_sig;
    end if;
    if not (select prosecdef from pg_catalog.pg_proc where oid=v_oid) then
      raise exception 'Expected SECURITY DEFINER function: %', v_sig;
    end if;
    execute pg_catalog.format('alter function %s set search_path = pg_catalog, public', v_oid::regprocedure);
  end loop;
end
$$;
