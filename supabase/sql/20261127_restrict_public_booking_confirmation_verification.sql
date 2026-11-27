-- READ ONLY verification for owner-only confirm_public_booking privileges.
-- Run after the companion SQL patch in isolated staging.

do $verify$
declare
  v_oid oid := to_regprocedure('public.confirm_public_booking(uuid)');
  v_body text;
  v_config text[];
begin
  if v_oid is null then raise exception 'confirm_public_booking(uuid) is missing'; end if;
  select p.prosrc,p.proconfig into v_body,v_config from pg_proc p where p.oid=v_oid;

  if not (select prosecdef from pg_proc where oid=v_oid) then
    raise exception 'Function must remain SECURITY DEFINER';
  end if;
  if position('private.has_owner_role()' in v_body)=0 or position('auth.uid() is null' in v_body)=0 then
    raise exception 'Owner-role authorization guard is missing';
  end if;
  if position('serzh.xz@mail.ru' in v_body)>0 then
    raise exception 'Legacy fixed-email guard remains';
  end if;
  if v_config is distinct from array['search_path=pg_catalog']::text[] then
    raise exception 'Function search_path is not pinned';
  end if;
  if has_function_privilege('anon',v_oid,'EXECUTE') then
    raise exception 'Anonymous execution must be revoked';
  end if;
  if not has_function_privilege('authenticated',v_oid,'EXECUTE') then
    raise exception 'Authenticated owner execution must be preserved';
  end if;
  if has_function_privilege('service_role',v_oid,'EXECUTE') then
    raise exception 'Service role execution is not part of the owner-only caller contract';
  end if;
  if exists (
    select 1 from aclexplode(coalesce((select proacl from pg_proc where oid=v_oid),acldefault('f',(select proowner from pg_proc where oid=v_oid)))) a
    where a.grantee=0 and a.privilege_type='EXECUTE'
  ) then raise exception 'Implicit PUBLIC EXECUTE remains'; end if;
end
$verify$;

select p.oid::regprocedure as signature,p.prosecdef,p.proconfig,
       p.prosrc ilike '%private.has_owner_role()%' as owner_role_guard,
       p.prosrc ilike '%serzh.xz@mail.ru%' as legacy_email_guard,
       has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
       has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute,
       has_function_privilege('service_role',p.oid,'EXECUTE') as service_role_execute
from pg_proc p
where p.oid=to_regprocedure('public.confirm_public_booking(uuid)');
