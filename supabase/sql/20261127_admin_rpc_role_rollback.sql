-- FreeDom role-based RPC rollback (STAGING ONLY; manual approval required).
-- Restores the previous fixed-owner-email authorization and public search_path
-- for exactly the 12 functions changed by 20261127_admin_rpc_role_migration.sql.
-- This does not drop role tables/helpers or alter role assignments.
-- Do not run automatically. Use only if the role migration causes a verified
-- regression and the owner-email account remains the approved emergency operator.

begin;

do $rollback$
declare
  f record;
  v_definition text;
  v_new_definition text;
  v_guard text;
  v_changed integer := 0;
begin
  for f in
    select p.oid, p.proname, pg_get_function_identity_arguments(p.oid) as identity_args
    from pg_proc p
    join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public'
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
    v_guard := case
      when f.proname in (
        'admin_get_bookings','admin_get_kitchen_orders',
        'admin_update_kitchen_order_status','confirm_booking','cancel_booking'
      ) then 'private.has_admin_role()'
      else 'private.has_owner_role()'
    end;

    v_definition := pg_get_functiondef(f.oid);
    if position(v_guard in v_definition) = 0 then
      raise exception 'Expected role guard % not found in %. Rollback aborted', v_guard, f.proname;
    end if;

    v_new_definition := replace(
      v_definition,
      'if auth.uid() is null or not ' || v_guard || ' then',
      'if auth.email() is distinct from ''serzh.xz@mail.ru'' then'
    );

    if v_new_definition = v_definition then
      raise exception 'Could not restore owner guard in %. Rollback aborted', f.proname;
    end if;

    v_new_definition := regexp_replace(
      v_new_definition,
      'SET search_path TO ''pg_catalog''',
      'SET search_path TO ''public''',
      'gi'
    );

    execute v_new_definition;
    v_changed := v_changed + 1;
  end loop;

  if v_changed <> 12 then
    raise exception 'Rollback coverage mismatch: restored %, expected 12', v_changed;
  end if;

  raise notice 'Rollback complete: restored legacy owner-email checks for % RPCs', v_changed;
end
$rollback$;

commit;

-- Post-rollback: run the original admin RPC guard verification and confirm
-- every function denies anon and non-owner identities. The DISTINCT FROM
-- comparison remains NULL-safe, unlike the original <> comparison.
