-- Emergency staging rollback for 20261127_harden_remaining_admin_rpcs.sql.
-- Restores the prior fixed-email checks while keeping search_path=pg_catalog.
-- Run only if no dependent RPC replacement has been applied afterward.
-- This is not a production target state.
begin;

do $rollback$
declare
  v_sig text;
  v_oid oid;
  v_def text;
  v_new text;
  v_changed integer := 0;
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
    v_oid := to_regprocedure(v_sig);
    if v_oid is null then raise exception 'Required function missing: %',v_sig; end if;
    v_def := pg_get_functiondef(v_oid);
    v_new := replace(v_def,
      'if auth.uid() is null or not private.has_owner_role() then',
      'if auth.email() is distinct from ''serzh.xz@mail.ru'' then');
    v_new := replace(v_new,
      'where private.has_owner_role()',
      'where auth.uid() is not null and auth.email() = ''serzh.xz@mail.ru''');
    if v_new=v_def then
      raise exception 'No owner guard found to roll back in %; aborting',v_sig;
    end if;
    execute v_new;
    -- Deliberately retain the hardened pg_catalog search_path.
    execute format('alter function %s set search_path = pg_catalog',v_oid::regprocedure);
    v_changed:=v_changed+1;
  end loop;
  if v_changed<>12 then raise exception 'Unexpected rollback coverage: %',v_changed; end if;
end
$rollback$;

commit;
