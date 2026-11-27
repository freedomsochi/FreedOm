-- FreeDom admin CRM RPC role follow-up.
-- SOURCE-ONLY. Requires admin-role-foundation.sql and approved staging role assignments.
-- Replaces remaining fixed-email guards in guest, booking-overview and payment RPCs.
begin;

do $migration$
declare
  v record;
  v_def text;
  v_new text;
  v_admin_guard constant text := 'if auth.uid() is null or not private.has_admin_role() then';
  v_owner_guard constant text := 'if auth.uid() is null or not private.has_owner_role() then';
begin
  if to_regclass('private.user_roles') is null
     or to_regprocedure('private.has_admin_role()') is null
     or to_regprocedure('private.has_owner_role()') is null then
    raise exception 'Role foundation missing; apply and validate admin-role-foundation.sql in staging first';
  end if;

  for v in
    select * from (values
      ('public.admin_get_bookings_overview()', 'admin'),
      ('public.admin_get_guest_dashboard_stats()', 'admin'),
      ('public.admin_get_guest_profile(uuid)', 'admin'),
      ('public.admin_get_guests_overview()', 'admin'),
      ('public.admin_record_guest_payment(uuid,integer,text,text,uuid)', 'owner')
    ) as targets(signature, required_role)
  loop
    if to_regprocedure(v.signature) is null then
      raise exception 'Required RPC missing: %', v.signature;
    end if;
    select pg_get_functiondef(to_regprocedure(v.signature)) into v_def;
    v_new := v_def;

    if v.signature = 'public.admin_get_guest_dashboard_stats()' then
      v_new := replace(v_new,
        'where auth.uid() is not null and auth.email() = ''serzh.xz@mail.ru'';',
        'where auth.uid() is not null and private.has_admin_role();');
    elsif v.signature = 'public.admin_get_guest_profile(uuid)' then
      v_new := replace(v_new,
        'if v_email is null or v_email <> ''serzh.xz@mail.ru'' then',
        v_admin_guard);
      -- The profile UI uses only these four identity fields. Do not serialize
      -- every users-table column into the browser response.
      v_new := replace(v_new,
        'select to_jsonb(u) into v_user from public.users u where u.user_id=p_user_id;',
        'select jsonb_build_object(''user_id'',u.user_id,''Display_name'',u."Display_name",''Phone'',u."Phone",''Email'',u."Email",''City'',u."City") into v_user from public.users u where u.user_id=p_user_id;');
    elsif v.signature = 'public.admin_record_guest_payment(uuid,integer,text,text,uuid)' then
      v_new := replace(v_new,
        'if v_email is null or v_email <> ''serzh.xz@mail.ru'' then',
        v_owner_guard);
    else
      v_new := replace(v_new,
        'if auth.email() is distinct from ''serzh.xz@mail.ru'' then',
        v_admin_guard);
    end if;

    if v_new = v_def then
      raise exception 'No expected fixed-email guard changed in %; aborting', v.signature;
    end if;

    execute v_new;
    execute format('alter function %s set search_path = pg_catalog', to_regprocedure(v.signature));
    execute format('revoke all on function %s from public, anon', to_regprocedure(v.signature));
    execute format('grant execute on function %s to authenticated', to_regprocedure(v.signature));
  end loop;

  -- Postconditions: every target has its required guard and fixed search_path.
  if exists (
    select 1
    from pg_proc p
    where p.oid in (
      to_regprocedure('public.admin_get_bookings_overview()'),
      to_regprocedure('public.admin_get_guest_dashboard_stats()'),
      to_regprocedure('public.admin_get_guest_profile(uuid)'),
      to_regprocedure('public.admin_get_guests_overview()'),
      to_regprocedure('public.admin_record_guest_payment(uuid,integer,text,text,uuid)')
    )
    and (
      p.prosrc ilike '%serzh.xz@mail.ru%'
      or coalesce(array_to_string(p.proconfig,','),'') not ilike '%search_path=pg_catalog%'
    )
  ) then
    raise exception 'Postcondition failed: fixed email or mutable search_path remains';
  end if;
  if position('jsonb_build_object(''user_id''' in pg_get_functiondef('public.admin_get_guest_profile(uuid)'::regprocedure))=0 then
    raise exception 'Guest profile still serializes full users row';
  end if;
end
$migration$;

commit;
