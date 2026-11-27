-- Emergency rollback for staging only.
-- Reinstates the prior fixed-email guards and public search_path on the five
-- affected functions. This is intentionally not a production target state.
begin;

do $rollback$
declare
  v_sig text;
  v_oid oid;
  v_def text;
  v_new text;
begin
  foreach v_sig in array array[
    'public.admin_get_bookings_overview()',
    'public.admin_get_guest_dashboard_stats()',
    'public.admin_get_guest_profile(uuid)',
    'public.admin_get_guests_overview()',
    'public.admin_record_guest_payment(uuid,integer,text,text,uuid)'
  ] loop
    v_oid := to_regprocedure(v_sig);
    if v_oid is null then raise exception 'Function missing: %',v_sig; end if;
    v_def := pg_get_functiondef(v_oid);
    v_new := v_def;
    v_new := replace(v_new,'if auth.uid() is null or not private.has_admin_role() then',
      'if auth.email() is distinct from ''serzh.xz@mail.ru'' then');
    v_new := replace(v_new,'if auth.uid() is null or not private.has_owner_role() then',
      'if v_email is null or v_email <> ''serzh.xz@mail.ru'' then');
    v_new := replace(v_new,'where auth.uid() is not null and private.has_admin_role();',
      'where auth.uid() is not null and auth.email() = ''serzh.xz@mail.ru'';');
    if v_sig='public.admin_get_guest_profile(uuid)' then
      v_new := replace(v_new, '''payments'',v_payments,''can_record_payments'',private.has_owner_role());', '''payments'',v_payments);');
      v_new := replace(v_new,
        'select jsonb_build_object(''user_id'',u.user_id,''Display_name'',u."Display_name",''Phone'',u."Phone",''Email'',u."Email",''City'',u."City") into v_user from public.users u where u.user_id=p_user_id;',
        'select to_jsonb(u) into v_user from public.users u where u.user_id=p_user_id;');
    end if;
    execute v_new;
    execute format('alter function %s set search_path = public',v_oid::regprocedure);
  end loop;
end
$rollback$;

commit;
