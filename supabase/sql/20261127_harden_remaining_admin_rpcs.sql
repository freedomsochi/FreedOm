-- FreeDom: convert the remaining admin read/payment RPCs to owner-role authorization.
-- SOURCE-ONLY STAGING MIGRATION. Do not apply to production without explicit approval.
-- Conservative policy: all 12 functions expose guest identity, financial, or
-- room-occupancy details; they remain owner-only until a narrower admin scope
-- is explicitly approved.
begin;

do $migration$
declare
  v_sig text;
  v_oid oid;
  v_def text;
  v_changed integer := 0;
  v_expected integer := 12;
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
  if to_regclass('private.user_roles') is null
     or to_regprocedure('private.has_owner_role()') is null then
    raise exception 'Role foundation missing; apply and verify it in isolated staging first';
  end if;

  if not exists (select 1 from private.user_roles where role='owner') then
    raise exception 'No owner role is assigned; refusing to replace the existing authorization path';
  end if;

  foreach v_sig in array v_targets loop
    v_oid := pg_catalog.to_regprocedure(v_sig);
    if v_oid is null then
      raise exception 'Required function missing: %', v_sig;
    end if;

    if not (select prosecdef from pg_catalog.pg_proc where oid=v_oid) then
      raise exception 'Expected SECURITY DEFINER function: %', v_sig;
    end if;

    if exists (
      select 1 from pg_catalog.pg_proc h
      where h.oid='private.has_owner_role()'::regprocedure
        and h.proowner<>(select proowner from pg_catalog.pg_proc where oid=v_oid)
    ) then
      raise exception 'Role helper owner mismatch for %', v_sig;
    end if;

    v_def := pg_catalog.pg_get_functiondef(v_oid);

    -- PL/pgSQL guards that compare auth.email() directly or via v_email.
    v_def := pg_catalog.regexp_replace(
      v_def,
      'if[[:space:]]+auth[.]email[(][)][[:space:]]+is[[:space:]]+distinct[[:space:]]+from[[:space:]]+''serzh[.]xz@mail[.]ru''[[:space:]]+then',
      'if auth.uid() is null or not private.has_owner_role() then',
      'gi'
    );
    v_def := pg_catalog.regexp_replace(
      v_def,
      'if[[:space:]]+v_email[[:space:]]+is[[:space:]]+null[[:space:]]+or[[:space:]]+v_email[[:space:]]*<>[[:space:]]*''serzh[.]xz@mail[.]ru''[[:space:]]+then',
      'if auth.uid() is null or not private.has_owner_role() then',
      'gi'
    );

    -- SQL-language read RPCs use a fail-closed WHERE predicate rather than IF.
    v_def := pg_catalog.regexp_replace(
      v_def,
      'where[[:space:]]+auth[.]uid[(][)][[:space:]]+is[[:space:]]+not[[:space:]]+null[[:space:]]+and[[:space:]]+auth[.]email[(][)][[:space:]]*=[[:space:]]*''serzh[.]xz@mail[.]ru''',
      'where private.has_owner_role()',
      'gi'
    );

    if pg_catalog.strpos(v_def, 'private.has_owner_role()') = 0 then
      raise exception 'No supported authorization pattern replaced in %; migration aborted', v_sig;
    end if;

    execute v_def;
    execute pg_catalog.format('alter function %s set search_path = pg_catalog', v_oid::regprocedure);
    v_changed := v_changed + 1;
  end loop;

  if v_changed <> v_expected then
    raise exception 'Unexpected coverage: changed %, expected %', v_changed, v_expected;
  end if;

  if exists (
    select 1
    from pg_catalog.pg_proc p
    join pg_catalog.pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public'
      and p.proname in (
        'admin_get_bookings_overview','admin_get_finance_overview',
        'admin_get_guest_dashboard_stats','admin_get_guest_profile',
        'admin_get_guests_overview','admin_get_rooms',
        'admin_get_space_location','admin_get_space_navigation',
        'admin_get_space_overview','admin_get_user_debts','admin_get_users',
        'admin_record_guest_payment'
      )
      and (p.prosrc not ilike '%private.has_owner_role()%'
           or coalesce(array_to_string(p.proconfig,','),'') not like '%search_path=pg_catalog%')
  ) then
    raise exception 'Postcondition failed: stale guard or unsafe search_path remains';
  end if;
end
$migration$;

commit;

-- Staging only: run 20261127_harden_remaining_admin_rpcs_verification.sql.
-- Test anon, ordinary authenticated, admin-only and owner identities.
-- This migration intentionally leaves grants and business logic unchanged.
