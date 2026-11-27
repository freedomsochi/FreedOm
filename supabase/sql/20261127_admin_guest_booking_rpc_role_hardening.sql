-- Guest profile data minimization and owner payment capability.
-- SOURCE-ONLY STAGING FOLLOW-UP.
-- Prerequisite: apply 20261127_harden_remaining_admin_rpcs.sql in staging.
-- This file deliberately does not duplicate or replace its owner-role guard.
begin;

do $migration$
declare
  v_oid oid := to_regprocedure('public.admin_get_guest_profile(uuid)');
  v_def text;
  v_new text;
begin
  if v_oid is null then
    raise exception 'Missing public.admin_get_guest_profile(uuid)';
  end if;
  if not exists (
    select 1 from pg_proc p
    where p.oid=v_oid
      and p.prosecdef
      and p.prosrc ilike '%private.has_owner_role()%'
      and coalesce(array_to_string(p.proconfig,','),'') like '%search_path=pg_catalog%'
  ) then
    raise exception 'Guest profile RPC must first pass the owner-role hardening migration';
  end if;

  v_def := pg_get_functiondef(v_oid);
  v_new := replace(v_def,
    'select to_jsonb(u) into v_user from public.users u where u.user_id=p_user_id;',
    'select jsonb_build_object(''user_id'',u.user_id,''Display_name'',u."Display_name",''Phone'',u."Phone",''Email'',u."Email",''City'',u."City") into v_user from public.users u where u.user_id=p_user_id;');

  v_new := replace(v_new,
    '''payments'',v_payments);',
    '''payments'',v_payments,''can_record_payments'',private.has_owner_role());');

  if v_new=v_def then
    raise exception 'No guest profile projection or capability change generated';
  end if;
  if position('jsonb_build_object(''user_id''' in v_new)=0
     or position('can_record_payments' in v_new)=0 then
    raise exception 'Guest profile projection/capability postcondition failed';
  end if;

  execute v_new;
  execute format('alter function %s set search_path = pg_catalog',v_oid::regprocedure);
end
$migration$;

commit;
