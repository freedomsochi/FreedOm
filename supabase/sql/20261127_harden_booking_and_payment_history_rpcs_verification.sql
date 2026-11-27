-- Expected: five rows, all guard_ok/search_path_ok/authenticated_exec=true,
-- anon_exec/public_exec=false.
select
  p.oid::regprocedure as signature,
  pg_catalog.strpos(pg_catalog.pg_get_functiondef(p.oid),
    'if auth.uid() is null or auth.email() is distinct from ''serzh.xz@mail.ru'' then') > 0 as guard_ok,
  coalesce(p.proconfig @> array['search_path=pg_catalog'], false) as search_path_ok,
  has_function_privilege('authenticated', p.oid, 'execute') as authenticated_exec,
  has_function_privilege('anon', p.oid, 'execute') as anon_exec,
  has_function_privilege('public', p.oid, 'execute') as public_exec
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.oid in (
    to_regprocedure('public.admin_get_bookings()'),
    to_regprocedure('public.cancel_booking(uuid)'),
    to_regprocedure('public.confirm_booking(uuid)'),
    to_regprocedure('public.get_payment_history(uuid,uuid)'),
    to_regprocedure('public.get_user_payment_history(uuid)')
  )
order by 1;
