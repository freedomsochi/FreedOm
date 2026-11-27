-- FreeDom finance RPC authorization hardening.
-- SOURCE / STAGING REVIEW ONLY. Do not apply directly to production.
--
-- Fixes SQL NULL bypass in auth.email() <> checks and adds the missing
-- administrator check to record_event_registration_payment().
-- Existing authenticated/service_role grants are preserved; implicit PUBLIC
-- execution is revoked. Every function gets a fixed pg_catalog search_path.

begin;

set local search_path = public, pg_catalog;

do $patch$
declare
  v_sig text;
  v_oid oid;
  v_def text;
  v_new text;
  v_changed integer := 0;
begin
  foreach v_sig in array array[
    'public.add_service_order(uuid,uuid,integer,text)',
    'public.create_manual_guest(text,text,text,text,date,text)',
    'public.get_payment_history(uuid,uuid)',
    'public.get_user_payment_history(uuid)',
    'public.record_payment(uuid,uuid,integer,text,text)',
    'public.record_user_payment(uuid,integer,text,text)',
    'public.record_user_payment_for_charge(uuid,text,uuid,integer,text,text)'
  ]
  loop
    v_oid := to_regprocedure(v_sig);
    if v_oid is null then
      raise exception 'Required finance RPC missing: %', v_sig;
    end if;

    v_def := pg_get_functiondef(v_oid);
    v_new := regexp_replace(
      v_def,
      'auth[.]email[(][)]\s*<>\s*''serzh[.]xz@mail[.]ru''',
      'auth.email() IS DISTINCT FROM ''serzh.xz@mail.ru''',
      'gi'
    );

    if v_new = v_def then
      raise exception 'No fixed-email guard found to harden in %', v_sig;
    end if;

    execute v_new;
    execute format('alter function %s set search_path = pg_catalog', v_sig);
    execute format('revoke all on function %s from public', v_sig);
    v_changed := v_changed + 1;
  end loop;

  v_sig := 'public.record_event_registration_payment(uuid,integer,text)';
  v_oid := to_regprocedure(v_sig);
  if v_oid is null then
    raise exception 'Required finance RPC missing: %', v_sig;
  end if;

  v_def := pg_get_functiondef(v_oid);
  if v_def ilike '%auth.email()%'
     or v_def ilike '%auth.uid()%' then
    raise exception 'Unexpected existing caller identity guard in %', v_sig;
  end if;

  v_new := replace(
    v_def,
    E'BEGIN\n',
    E'BEGIN\n  IF auth.email() IS DISTINCT FROM ''serzh.xz@mail.ru'' THEN\n    RAISE EXCEPTION ''Доступ запрещён'';\n  END IF;\n'
  );

  if v_new = v_def then
    raise exception 'Could not insert administrator guard into %', v_sig;
  end if;

  execute v_new;
  execute format('alter function %s set search_path = pg_catalog', v_sig);
  execute format('revoke all on function %s from public', v_sig);
  v_changed := v_changed + 1;

  if v_changed <> 8 then
    raise exception 'Unexpected number of hardened functions: %', v_changed;
  end if;
end
$patch$;

commit;
