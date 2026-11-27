-- Source-only hardening. Do not apply to production until coordinated admin-role rollout.
begin;
create or replace function public.record_event_registration_payment(
  p_registration_id uuid, p_amount integer, p_payment_method text
)
returns public.event_registrations
language plpgsql
security definer
set search_path = pg_catalog
as $function$
declare
  r public.event_registrations;
  v_payment_id uuid;
  v_remaining integer;
  v_method text;
begin
  if auth.uid() is null
     or auth.email() is distinct from 'serzh.xz@mail.ru' then
    raise exception 'Доступ запрещён' using errcode = '42501';
  end if;
  if p_registration_id is null then raise exception 'Не указана регистрация'; end if;
  if p_amount is null or p_amount <= 0 then raise exception 'Сумма оплаты должна быть больше 0'; end if;

  select * into r from public.event_registrations
   where id = p_registration_id for update;
  if not found then raise exception 'Регистрация не найдена'; end if;
  if r.user_id is null then raise exception 'У регистрации нет привязанного пользователя'; end if;

  v_remaining := greatest(coalesce(r.amount, 0) - coalesce(r.paid_amount, 0), 0);
  if v_remaining = 0 then raise exception 'Регистрация уже оплачена'; end if;
  if p_amount > v_remaining then raise exception 'Оплата превышает остаток: %', v_remaining; end if;

  v_method := coalesce(nullif(pg_catalog.btrim(p_payment_method), ''), 'Перевод');
  insert into public.payments(user_id, amount, payment_method, method, status, note, created_by)
  values (r.user_id, p_amount, v_method, v_method, 'успешно',
          'Оплата события: ' || r.event_id::text, auth.uid())
  returning id into v_payment_id;

  insert into public.payment_allocations(payment_id, event_registration_id, amount)
  values (v_payment_id, r.id, p_amount);

  update public.event_registrations
     set paid_amount = coalesce(paid_amount, 0) + p_amount,
         payment_status = case
           when coalesce(paid_amount, 0) + p_amount >= coalesce(amount, 0) then 'paid'
           else 'partial'
         end,
         updated_at = pg_catalog.now()
   where id = r.id
   returning * into r;
  return r;
end;
$function$;
revoke all on function public.record_event_registration_payment(uuid, integer, text) from public;
revoke all on function public.record_event_registration_payment(uuid, integer, text) from anon;
grant execute on function public.record_event_registration_payment(uuid, integer, text) to authenticated, service_role;
commit;
