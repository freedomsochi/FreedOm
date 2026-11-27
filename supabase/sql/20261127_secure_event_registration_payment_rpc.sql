-- FreeDom: secure event-registration payment mutation.
-- STAGING / SOURCE ARTIFACT ONLY. Do not apply to production without approval.
-- Prerequisite: admin-role-foundation.sql has been applied in isolated staging,
-- private.has_owner_role() exists, and the intended owner test identity is assigned.
-- Existing function signature, return type, default, row lock and accounting logic are preserved.

begin;

do $preflight$
declare
  v_oid oid;
  v_def text;
  v_owner text;
begin
  v_oid := to_regprocedure('public.record_event_registration_payment(uuid,integer,text)');
  if v_oid is null then
    raise exception 'Required RPC public.record_event_registration_payment(uuid,integer,text) is missing';
  end if;

  select pg_get_functiondef(v_oid), pg_get_userbyid(proowner)
    into v_def, v_owner
  from pg_proc where oid = v_oid;

  if v_def not like '%SET search_path TO ''public''%' then
    raise exception 'Unexpected function search_path; review definition before applying';
  end if;
  if v_def not like '%INSERT INTO public.payment_allocations%' then
    raise exception 'Unexpected function body; payment allocation logic changed';
  end if;
  if to_regprocedure('private.has_owner_role()') is null then
    raise exception 'private.has_owner_role() prerequisite is missing';
  end if;
  if (select pg_get_userbyid(proowner) from pg_proc
      where oid = to_regprocedure('private.has_owner_role()')) <> v_owner then
    raise exception 'Role helper owner differs from protected RPC owner';
  end if;
end;
$preflight$;

create or replace function public.record_event_registration_payment(
  p_registration_id uuid,
  p_amount integer,
  p_payment_method text default 'Перевод'::text
)
returns public.event_registrations
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  r public.event_registrations;
  payment_id uuid;
  remaining integer;
begin
  -- Fail closed before touching registration or financial rows.
  if auth.uid() is null or not private.has_owner_role() then
    raise exception 'Недостаточно прав для проведения оплаты события'
      using errcode = '42501';
  end if;

  select * into r
  from public.event_registrations
  where id = p_registration_id
  for update;

  if not found then raise exception 'Регистрация не найдена'; end if;
  if p_amount is null or p_amount <= 0 then
    raise exception 'Сумма оплаты должна быть больше 0';
  end if;
  if r.user_id is null then
    raise exception 'У регистрации нет привязанного пользователя';
  end if;

  remaining := greatest(coalesce(r.amount,0) - coalesce(r.paid_amount,0), 0);
  if remaining = 0 then raise exception 'Регистрация уже оплачена'; end if;
  if p_amount > remaining then
    raise exception 'Оплата превышает остаток: %', remaining;
  end if;

  insert into public.payments(user_id, amount, payment_method, method, status, note)
  values (
    r.user_id,
    p_amount,
    coalesce(nullif(trim(p_payment_method),''),'Перевод'),
    coalesce(nullif(trim(p_payment_method),''),'Перевод'),
    'успешно',
    'Оплата события: ' || r.event_id::text
  )
  returning id into payment_id;

  insert into public.payment_allocations(payment_id, event_registration_id, amount)
  values (payment_id, r.id, p_amount);

  update public.event_registrations
  set paid_amount = coalesce(paid_amount,0) + p_amount,
      payment_status = case
        when coalesce(paid_amount,0) + p_amount >= coalesce(amount,0) then 'paid'
        else 'partial'
      end,
      updated_at = now()
  where id = r.id
  returning * into r;

  return r;
end;
$function$;

-- Preserve the existing authenticated EXECUTE ACL; authorization is now enforced
-- inside the SECURITY DEFINER body. No PUBLIC or anon grant is added.
do $postflight$
declare
  v_def text;
begin
  select pg_get_functiondef('public.record_event_registration_payment(uuid,integer,text)'::regprocedure)
    into v_def;

  if v_def not like '%auth.uid() is null or not private.has_owner_role()%' then
    raise exception 'Postcondition failed: owner guard is absent';
  end if;
  if has_function_privilege('anon',
       'public.record_event_registration_payment(uuid,integer,text)'::regprocedure,
       'EXECUTE') then
    raise exception 'Postcondition failed: anon must not execute this RPC';
  end if;
  if not has_function_privilege('authenticated',
       'public.record_event_registration_payment(uuid,integer,text)'::regprocedure,
       'EXECUTE') then
    raise exception 'Postcondition failed: authenticated caller ACL unexpectedly changed';
  end if;
end;
$postflight$;

commit;
