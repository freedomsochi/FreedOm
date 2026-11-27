-- FreeDom: replace fixed-email checks with protected owner/admin roles.
-- SOURCE-ONLY STAGING MIGRATION. Do not apply to production without explicit release approval.
-- Prerequisite: apply admin-role-foundation.sql in isolated staging and assign
-- test roles through a separately controlled owner procedure.
--
-- This migration changes only the 12 enumerated SECURITY DEFINER RPC guards
-- and their fixed search_path. It preserves signatures, defaults, return types,
-- grants, owners, and function business logic.

begin;

do $migration$
declare
  f record;
  v_definition text;
  v_new_definition text;
  v_guard text;
  v_expected integer := 12;
  v_changed integer := 0;
  v_admin_count integer := 0;
  v_owner_count integer := 0;
begin
  if to_regclass('private.user_roles') is null
     or to_regprocedure('private.has_admin_role()') is null
     or to_regprocedure('private.has_owner_role()') is null then
    raise exception 'Role foundation missing: apply admin-role-foundation.sql in staging first';
  end if;

  -- Critical lockout prevention: never replace the only working owner-email
  -- guard unless a verified owner role already exists in the protected table.
  -- The migration intentionally does not create or guess an owner identity.
  if not exists (select 1 from private.user_roles where role = 'owner') then
    raise exception 'No owner role is assigned. Assign and verify a staging owner before migrating RPC guards';
  end if;

  for f in
    select p.oid,
           p.proname,
           pg_get_function_identity_arguments(p.oid) as identity_args,
           p.proowner
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and p.prosecdef
       and (p.proname, pg_get_function_identity_arguments(p.oid)) in (
         ('admin_get_bookings', ''),
         ('admin_get_kitchen_orders', ''),
         ('admin_update_kitchen_order_status', 'p_order_id uuid, p_status text'),
         ('confirm_booking', 'p_booking_id uuid'),
         ('cancel_booking', 'p_booking_id uuid'),
         ('add_service_order', 'p_user_id uuid, p_service_id uuid, p_quantity integer, p_comment text'),
         ('create_manual_guest', 'p_name text, p_phone text, p_email text, p_city text, p_birth_date date, p_comment text'),
         ('get_payment_history', 'p_booking_id uuid, p_order_id uuid'),
         ('get_user_payment_history', 'p_user_id uuid'),
         ('record_payment', 'p_booking_id uuid, p_order_id uuid, p_amount integer, p_payment_method text, p_note text'),
         ('record_user_payment', 'p_user_id uuid, p_amount integer, p_payment_method text, p_note text'),
         ('record_user_payment_for_charge', 'p_user_id uuid, p_charge_type text, p_charge_id uuid, p_amount integer, p_payment_method text, p_note text')
       )
     order by p.proname
  loop
    -- The helper must execute as the same trusted owner as the protected RPC.
    if exists (
      select 1 from pg_proc h
      where h.oid in (
        'private.has_admin_role()'::regprocedure,
        'private.has_owner_role()'::regprocedure
      )
      and h.proowner <> f.proowner
    ) then
      raise exception 'Role helper owner mismatch for %. Run this migration as the trusted function owner', f.proname;
    end if;

    v_definition := pg_get_functiondef(f.oid);
    v_guard := case
      when f.proname in (
        'admin_get_bookings',
        'admin_get_kitchen_orders',
        'admin_update_kitchen_order_status',
        'confirm_booking',
        'cancel_booking'
      ) then 'private.has_admin_role()'
      else 'private.has_owner_role()'
    end;

    v_new_definition := regexp_replace(
      v_definition,
      'if[[:space:]]+auth[.]email[(][)][[:space:]]*<>[[:space:]]*''serzh[.]xz@mail[.]ru''[[:space:]]+then',
      'if auth.uid() is null or not ' || v_guard || ' then',
      'gi'
    );

    if v_new_definition = v_definition then
      raise exception 'Expected fixed-email guard not found in %. Migration aborted', f.proname;
    end if;

    -- A fixed pg_catalog search_path prevents public-schema object shadowing.
    v_new_definition := regexp_replace(
      v_new_definition,
      'SET search_path TO ''public''',
      'SET search_path TO ''pg_catalog''',
      'gi'
    );

    if v_new_definition = v_definition then
      raise exception 'No function definition change generated for %. Migration aborted', f.proname;
    end if;

    execute v_new_definition;
    v_changed := v_changed + 1;

    if v_guard = 'private.has_admin_role()' then
      v_admin_count := v_admin_count + 1;
    else
      v_owner_count := v_owner_count + 1;
    end if;
  end loop;

  if v_changed <> v_expected or v_admin_count <> 5 or v_owner_count <> 7 then
    raise exception 'Unexpected migration coverage: changed %, admin %, owner %; expected 12 / 5 / 7',
      v_changed, v_admin_count, v_owner_count;
  end if;

  -- Fail closed if any target function still contains the fixed email guard,
  -- uses a mutable public search_path, or lacks its assigned role helper.
  if exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prosecdef
      and p.proname in (
        'admin_get_bookings','admin_get_kitchen_orders',
        'admin_update_kitchen_order_status','confirm_booking','cancel_booking',
        'add_service_order','create_manual_guest','get_payment_history',
        'get_user_payment_history','record_payment','record_user_payment',
        'record_user_payment_for_charge'
      )
      and (
        p.prosrc ilike '%serzh.xz@mail.ru%'
        or coalesce(array_to_string(p.proconfig, ','), '') ilike '%search_path=public%'
        or (
          p.proname in ('admin_get_bookings','admin_get_kitchen_orders',
                        'admin_update_kitchen_order_status','confirm_booking','cancel_booking')
          and p.prosrc not ilike '%private.has_admin_role()%'
        )
        or (
          p.proname not in ('admin_get_bookings','admin_get_kitchen_orders',
                            'admin_update_kitchen_order_status','confirm_booking','cancel_booking')
          and p.prosrc not ilike '%private.has_owner_role()%'
        )
      )
  ) then
    raise exception 'Postcondition failed: stale email guard, public search_path, or missing role helper remains';
  end if;

  raise notice 'Role migration complete: % RPCs updated (5 operational admin, 7 owner-only)', v_changed;
end
$migration$;

commit;

-- Required staging follow-up:
-- 1. Run 20261127_admin_rpc_role_verification.sql and require PASS_STATIC_CHECKS.
-- 2. Verify existing function signatures, defaults, return types, owners and ACLs.
-- 3. Test anon, ordinary authenticated, admin, and owner identities.
-- 4. Use disposable records for confirm/cancel/status/payment tests; roll back fixtures.
-- 5. Verify service-role integrations separately. No service-role bypass is introduced here.
-- 6. Keep role assignment and production application outside this migration.
