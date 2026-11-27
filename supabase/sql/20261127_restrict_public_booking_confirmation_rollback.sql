-- Staging-only rollback for confirm_public_booking authorization.
-- Restores the former fixed-email body guard but deliberately keeps:
-- search_path=pg_catalog, no anon/PUBLIC EXECUTE, and authenticated-only ACL.
begin;

do $rollback$
declare
  v_oid oid := to_regprocedure('public.confirm_public_booking(uuid)');
  v_def text;
  v_new text;
begin
  if v_oid is null then raise exception 'confirm_public_booking(uuid) is missing'; end if;
  v_def := pg_get_functiondef(v_oid);
  v_new := replace(
    v_def,
    'if auth.uid() is null or not private.has_owner_role() then',
    'if coalesce(auth.jwt() ->> ''email'','''') <> ''serzh.xz@mail.ru'' then'
  );
  if v_new=v_def then raise exception 'Owner-role guard not found; refusing rollback'; end if;
  execute v_new;
  execute format('alter function %s set search_path = pg_catalog',v_oid::regprocedure);
end
$rollback$;

revoke all on function public.confirm_public_booking(uuid) from public;
revoke execute on function public.confirm_public_booking(uuid) from anon;
revoke execute on function public.confirm_public_booking(uuid) from service_role;
grant execute on function public.confirm_public_booking(uuid) to authenticated;

commit;
