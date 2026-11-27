-- Staging rollback for guest profile response minimization only.
-- Keeps the owner-role guard and fixed search_path installed by the prerequisite
-- hardening migration. It restores the former full users-row projection.
begin;

do $rollback$
declare
  v_oid oid := to_regprocedure('public.admin_get_guest_profile(uuid)');
  v_def text;
  v_new text;
begin
  if v_oid is null then raise exception 'Guest profile RPC missing'; end if;
  v_def := pg_get_functiondef(v_oid);
  v_new := replace(v_def,
    '''payments'',v_payments,''can_record_payments'',private.has_owner_role());',
    '''payments'',v_payments);');
  v_new := replace(v_new,
    'select jsonb_build_object(''user_id'',u.user_id,''Display_name'',u."Display_name",''Phone'',u."Phone",''Email'',u."Email",''City'',u."City") into v_user from public.users u where u.user_id=p_user_id;',
    'select to_jsonb(u) into v_user from public.users u where u.user_id=p_user_id;');
  if v_new=v_def then raise exception 'No guest profile rollback change generated'; end if;
  execute v_new;
  execute format('alter function %s set search_path = pg_catalog',v_oid::regprocedure);
end
$rollback$;

commit;
