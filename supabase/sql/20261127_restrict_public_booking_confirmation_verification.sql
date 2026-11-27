-- READ ONLY verification for confirm_public_booking privileges.
-- Run after the companion SQL patch in staging.

do $verify$
declare
  v_oid oid := to_regprocedure('public.confirm_public_booking(uuid)');
begin
  if v_oid is null then
    raise exception 'confirm_public_booking(uuid) is missing';
  end if;

  if has_function_privilege('anon',v_oid,'EXECUTE') then
    raise exception 'Anonymous execution must be revoked';
  end if;

  if not has_function_privilege('authenticated',v_oid,'EXECUTE') then
    raise exception 'Authenticated admin execution must be preserved';
  end if;

  if not has_function_privilege('service_role',v_oid,'EXECUTE') then
    raise exception 'Service role execution must be preserved';
  end if;

  if exists (
    select 1 from aclexplode(coalesce((select proacl from pg_proc where oid=v_oid),acldefault('f',(select proowner from pg_proc where oid=v_oid)))) a
    where a.grantee=0 and a.privilege_type='EXECUTE'
  ) then
    raise exception 'Implicit PUBLIC EXECUTE remains';
  end if;

  if (select proconfig from pg_proc where oid=v_oid) is distinct from array['search_path=pg_catalog']::text[] then
    raise exception 'Function search_path is not pinned';
  end if;
end
$verify$;

select
  p.oid::regprocedure as signature,
  p.proconfig,
  has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
  has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute,
  has_function_privilege('service_role',p.oid,'EXECUTE') as service_role_execute
from pg_proc p
where p.oid=to_regprocedure('public.confirm_public_booking(uuid)');
