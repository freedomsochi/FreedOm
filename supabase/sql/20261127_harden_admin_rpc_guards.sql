-- Source-only, catalog-preserving hardening for three admin RPCs.
-- Rewrites only the exact authorization predicate in the live function definitions.
begin;
do $block$
declare
  v_sig regprocedure;
  v_def text;
  v_old text := 'if auth.email() <> ''serzh.xz@mail.ru'' then';
  v_new text := 'if auth.uid() is null or auth.email() is distinct from ''serzh.xz@mail.ru'' then';
begin
  foreach v_sig in array array[
    'public.record_user_payment_for_charge(uuid,text,uuid,integer,text,text)'::regprocedure,
    'public.add_service_order(uuid,uuid,integer,text)'::regprocedure,
    'public.create_manual_guest(text,text,text,text,date,text)'::regprocedure
  ]
  loop
    v_def := pg_catalog.pg_get_functiondef(v_sig);
    if pg_catalog.strpos(v_def, v_old) = 0 then
      raise exception 'Expected legacy guard not found in %', v_sig;
    end if;
    v_def := pg_catalog.replace(v_def, v_old, v_new);
    if pg_catalog.strpos(v_def, v_old) > 0
       or pg_catalog.strpos(v_def, v_new) = 0 then
      raise exception 'Guard replacement verification failed for %', v_sig;
    end if;
    execute v_def;
    execute pg_catalog.format('alter function %s set search_path = pg_catalog', v_sig);
    execute pg_catalog.format('revoke all on function %s from public', v_sig);
    execute pg_catalog.format('revoke all on function %s from anon', v_sig);
    execute pg_catalog.format('grant execute on function %s to authenticated, service_role', v_sig);
  end loop;
end;
$block$;
commit;
