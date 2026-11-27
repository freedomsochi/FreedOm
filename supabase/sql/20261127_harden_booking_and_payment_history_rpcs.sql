-- Harden legacy admin booking and payment-history RPCs.
-- Source-only migration: do not apply to production without explicit approval.
do $$
declare
  v_sig text;
  v_oid oid;
  v_def text;
  v_old constant text := 'if auth.email() <> ''serzh.xz@mail.ru'' then';
  v_new constant text := 'if auth.uid() is null or auth.email() is distinct from ''serzh.xz@mail.ru'' then';
  v_role_guard text;
  v_targets text[] := array[
    'public.admin_get_bookings()',
    'public.cancel_booking(uuid)',
    'public.confirm_booking(uuid)',
    'public.get_payment_history(uuid,uuid)',
    'public.get_user_payment_history(uuid)',
    'public.admin_get_kitchen_orders()',
    'public.admin_update_kitchen_order_status(uuid,text)'
  ];
begin
  foreach v_sig in array v_targets loop
    v_oid := pg_catalog.to_regprocedure(v_sig);
    if v_oid is null then
      raise exception 'Required function missing: %', v_sig;
    end if;
    v_def := pg_catalog.pg_get_functiondef(v_oid);
    v_role_guard := case
      when v_sig in ('public.get_payment_history(uuid,uuid)', 'public.get_user_payment_history(uuid)')
        then 'private.has_owner_role()'
      else 'private.has_admin_role()'
    end;

    if pg_catalog.strpos(v_def, v_old) > 0 then
      v_def := pg_catalog.replace(v_def, v_old, v_new);
      execute v_def;
    elsif pg_catalog.strpos(v_def, v_role_guard) = 0 then
      raise exception 'Expected legacy email or matching role guard not found in %; aborting', v_sig;
    end if;
    execute pg_catalog.format('alter function %s set search_path = pg_catalog', v_oid::regprocedure);
    execute pg_catalog.format('revoke all on function %s from public, anon', v_oid::regprocedure);
    execute pg_catalog.format('grant execute on function %s to authenticated, service_role', v_oid::regprocedure);
  end loop;
end
$$;
