-- FreeDom admin RPC guard verification (READ ONLY; run after staging migration)
-- This script does not invoke RPCs or mutate database state.

-- A. Exact-pattern NULL-unsafe owner checks must be absent.
select p.oid::regprocedure as function_signature,
       p.prosrc
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.prosecdef
  and p.prosrc ilike '%serzh.xz@mail.ru%'
  and p.prosrc ~* 'if[[:space:]]+auth[.]email[(][)][[:space:]]*<>[[:space:]]*''serzh[.]xz@mail[.]ru''[[:space:]]+then';

-- B. Review every SECURITY DEFINER owner-email function and its EXECUTE ACL.
-- A true anon_execute value is not automatically a vulnerability: inspect the
-- function's intended public contract and internal authorization independently.
select p.oid::regprocedure as function_signature,
       p.prosecdef as security_definer,
       has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
       has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute,
       case
         when p.prosrc ~* 'auth[.]email[(][)][[:space:]]+is[[:space:]]+distinct[[:space:]]+from'
           then 'null_safe_distinct'
         when p.prosrc ~* 'v_email[[:space:]]+is[[:space:]]+null[[:space:]]+or'
           then 'null_safe_local_variable'
         when p.prosrc ~* 'coalesce[(]auth[.]jwt[(][)][[:space:]]*->[>]?[[:space:]]*''email'''
           then 'null_safe_jwt_coalesce'
         when p.prosrc ~* 'auth[.]uid[(][)][[:space:]]+is[[:space:]]+not[[:space:]]+null'
           then 'uid_present_check'
         when p.prosrc ~* 'auth[.]email[(][)][[:space:]]*<>'
           then 'REVIEW_NULL_COMPARISON'
         else 'manual_review'
       end as guard_pattern
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.prosecdef
  and p.prosrc ilike '%serzh.xz@mail.ru%'
order by guard_pattern,function_signature;

-- C. Inspect grants to PUBLIC/anon on privileged functions.
-- Expected: no PUBLIC or anon EXECUTE for admin-only RPCs. Do not blanket revoke
-- functions that intentionally serve anonymous public booking/availability.
select p.oid::regprocedure as function_signature,
       coalesce(array_to_string(p.proacl,','),'(default ACL)') as acl
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.prosecdef
  and p.prosrc ilike '%serzh.xz@mail.ru%'
order by function_signature;

-- D. Manual staging test matrix (execute separately with test identities):
-- 1. anon: all 12 formerly NULL-unsafe admin RPCs must raise insufficient_privilege.
-- 2. authenticated non-owner: same 12 RPCs must raise insufficient_privilege.
-- 3. authenticated identity with missing email claim: same 12 RPCs must fail closed.
-- 4. owner identity: read RPCs preserve results; mutation RPCs use disposable fixtures.
-- 5. Confirm transaction rollback after mutation tests and compare grants/function
--    signatures before and after. Never run mutation tests with real guest/payment IDs.
