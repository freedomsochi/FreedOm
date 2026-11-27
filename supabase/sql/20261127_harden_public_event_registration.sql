-- FreeDom: harden public event registration against account-linking abuse.
-- SOURCE / STAGING REVIEW ONLY. Do not apply to production without release approval.
--
-- Public visitors may register using guest contact details, but an unverified
-- phone number must never select or attach an existing user account.
-- Only the currently authenticated Auth user may be linked, and only when the
-- submitted phone exactly matches that user's verified Auth phone.
--
-- Existing registrations are not modified. Event registration remains callable
-- by anon/authenticated because the public website uses this RPC.

begin;

create or replace function public.create_event_registration(
  p_event_id uuid,
  p_guest_name text,
  p_phone text,
  p_email text default null,
  p_participants integer default 1,
  p_comment text default null
)
returns public.event_registrations
language plpgsql
security definer
set search_path = pg_catalog
as $function$
declare
  v_normalized_phone text;
  v_uid uuid := auth.uid();
  v_verified_phone text;
  v_event public.events;
  v_registration public.event_registrations;
  v_participants integer;
  v_amount bigint;
  v_email text;
  v_comment text;
begin
  -- Validate untrusted input before looking up or writing any records.
  if p_guest_name is null or length(btrim(p_guest_name)) not between 1 and 120 then
    raise exception 'Укажите имя (не более 120 символов)';
  end if;

  v_normalized_phone := public.normalize_phone(p_phone);
  if v_normalized_phone is null or v_normalized_phone !~ '^7[0-9]{10}$' then
    raise exception 'Телефон обязателен и должен содержать корректный номер';
  end if;

  v_participants := coalesce(p_participants, 1);
  if v_participants < 1 or v_participants > 30 then
    raise exception 'Количество участников должно быть от 1 до 30';
  end if;

  v_email := nullif(btrim(coalesce(p_email, '')), '');
  if v_email is not null and length(v_email) > 254 then
    raise exception 'Email слишком длинный';
  end if;

  v_comment := nullif(btrim(coalesce(p_comment, '')), '');
  if v_comment is not null and length(v_comment) > 1000 then
    raise exception 'Комментарий слишком длинный';
  end if;

  select e.*
    into v_event
    from public.events e
   where e.id = p_event_id
     and e.is_active = true
     and e.show_on_home = true;

  if not found then
    raise exception 'Событие недоступно для записи';
  end if;

  if coalesce(v_event.price, 0) < 0 then
    raise exception 'Для события указана некорректная стоимость';
  end if;

  v_amount := coalesce(v_event.price, 0)::bigint * v_participants::bigint;
  if v_amount > 2147483647 then
    raise exception 'Сумма записи превышает допустимое значение';
  end if;

  -- No lookup by guest-supplied phone. Link only the current authenticated
  -- identity when Supabase Auth confirms ownership of the same phone.
  if v_uid is not null then
    select u.phone
      into v_verified_phone
      from auth.users u
     where u.id = v_uid
       and u.phone_confirmed_at is not null;

    if v_verified_phone is not null
       and public.normalize_phone(v_verified_phone) = v_normalized_phone then
      null; -- v_uid is the verified owner of the submitted phone.
    else
      v_uid := null;
    end if;
  end if;

  insert into public.event_registrations (
    event_id,
    user_id,
    guest_name,
    guest_phone,
    guest_email,
    participants,
    amount,
    paid_amount,
    status,
    comment,
    phone
  )
  values (
    p_event_id,
    v_uid,
    btrim(p_guest_name),
    v_normalized_phone,
    v_email,
    v_participants,
    v_amount::integer,
    0,
    'new',
    v_comment,
    v_normalized_phone
  )
  returning * into v_registration;

  return v_registration;
end;
$function$;

-- The table trigger also used to resolve accounts from an unverified phone.
-- Replace that path as well: otherwise it would silently undo the RPC protection.
create or replace function public.attach_event_user_by_phone()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $trigger$
declare
  v_uid uuid := auth.uid();
  v_verified_phone text;
begin
  if new.user_id is not null or v_uid is null then
    return new;
  end if;

  select u.phone
    into v_verified_phone
    from auth.users u
   where u.id = v_uid
     and u.phone_confirmed_at is not null;

  if v_verified_phone is not null
     and public.normalize_phone(v_verified_phone) = public.normalize_phone(new.guest_phone) then
    new.user_id := v_uid;
  end if;

  return new;
end;
$trigger$;

-- Keep the intentional public-registration API, but remove the implicit
-- PUBLIC grant. Explicit role grants make the endpoint surface auditable.
revoke all on function public.create_event_registration(uuid, text, text, text, integer, text) from public;
grant execute on function public.create_event_registration(uuid, text, text, text, integer, text) to anon, authenticated, service_role;

commit;
