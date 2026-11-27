-- FreeDom: fail-closed owner guards for SECURITY DEFINER RPCs
-- REVIEWED STAGING MIGRATION. Do not apply to production without release approval.
-- Rewrites only the known null-unsafe fixed-owner comparison. It does not
-- change role policy, function signatures, grants, or business logic.

begin;

do $migration$
declare
  f record;
  v_definition text;
  v_new_definition text;
  v_changed integer := 0;
begin
  for f in
    select p.oid, n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) as identity_args
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and p.prosecdef
       and p.prosrc ilike '%auth.email()%'
       and p.prosrc ilike '%serzh.xz@mail.ru%'
  loop
    v_definition := pg_get_functiondef(f.oid);
    v_new_definition := v_definition;

    v_new_definition := regexp_replace(
      v_definition,
      'if[[:space:]]+auth\.email\(\)[[:space:]]*<>[[:space:]]*''serzh\.xz@mail\.ru''[[:space:]]+then',
      'if auth.uid() is null or auth.email() is distinct from ''serzh.xz@mail.ru'' then',
      'gi'
    );

    if v_new_definition <> v_definition then
      execute v_new_definition;
      v_changed := v_changed + 1;
    end if;
  end loop;

  -- Fail the transaction if any fixed-owner SECURITY DEFINER function still
  -- contains the exact NULL-unsafe comparison this migration is intended to fix.
  if exists (
    select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and p.prosecdef
       and p.prosrc ilike '%auth.email()%'
       and p.prosrc ilike '%serzh.xz@mail.ru%'
       and p.prosrc ~* 'if[[:space:]]+auth[.]email[(][)][[:space:]]*<>[[:space:]]*''serzh[.]xz@mail[.]ru''[[:space:]]+then'
  ) then
    raise exception 'Fail-closed migration incomplete: NULL-unsafe owner guard remains';
  end if;

  raise notice 'Updated % SECURITY DEFINER function definitions; residual exact-pattern check passed', v_changed;
end
$migration$;

commit;

-- Required staging assertions:
-- 1. Run the SECURITY DEFINER RPC inventory and confirm every remaining
--    fixed-email guard also checks auth.uid() IS NOT NULL.
-- 2. With anon and a normal authenticated account, calls fail with 42501.
-- 3. Owner calls retain their pre-existing behavior.
-- 4. No PUBLIC/anon grants or unrelated function definitions changed.
-- 5. Review the NOTICE count against the current function inventory (current audit baseline: 12).
-- 6. The migration aborts if an exact-pattern NULL-unsafe owner guard remains.
-- 7. Manually inspect any other owner-email guard syntax; this migration deliberately
--    does not rewrite DISTINCT FROM, COALESCE/JWT, local-variable, or unrelated guards.
