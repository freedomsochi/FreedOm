-- FreeDom: harden the legacy public-booking confirmation RPC.
-- Prerequisite: admin-role-foundation.sql must be applied in isolated staging,
-- and the intended operator must have an owner role.
-- Source-only script: do not apply to production without explicit approval.
begin;

do $migration$
declare
  v_oid oid := to_regprocedure('public.confirm_public_booking(uuid)');
  v_def text;
  v_new text;
begin
  if to_regclass('private.user_roles') is null
     or to_regprocedure('private.has_owner_role()') is null then
    raise exception 'Apply admin-role-foundation.sql before hardening confirm_public_booking';
  end if;
  if v_oid is null then
    raise exception 'public.confirm_public_booking(uuid) is missing';
  end if;

  v_def := pg_get_functiondef(v_oid);
  v_new := replace(
    v_def,
    'if coalesce(auth.jwt() ->> ''email'','''') <> ''serzh.xz@mail.ru'' then',
    'if auth.uid() is null or not private.has_owner_role() then'
  );

  if v_new = v_def then
    if position('private.has_owner_role()' in v_def) = 0 then
      raise exception 'Expected legacy email guard not found; refusing to rewrite function';
    end if;
  else
    execute v_new;
  end if;

  execute format('alter function %s set search_path = pg_catalog',v_oid::regprocedure);
end
$migration$;

revoke all on function public.confirm_public_booking(uuid) from public;
revoke execute on function public.confirm_public_booking(uuid) from anon;
revoke execute on function public.confirm_public_booking(uuid) from service_role;
grant execute on function public.confirm_public_booking(uuid) to authenticated;

commit;
