-- FreeDom: единый учёт оплат для бронирований и Veg-raw
-- Эта миграция уже применена в Supabase.

alter table public.orders
  add column if not exists paid_amount integer not null default 0,
  add column if not exists discount_amount integer not null default 0;

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references public.bookings(id) on delete cascade,
  order_id uuid references public.orders(id) on delete cascade,
  amount integer not null check (amount > 0),
  payment_method text not null default 'Перевод',
  note text,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint payments_one_parent check ((booking_id is not null) <> (order_id is not null))
);

create index if not exists payments_booking_id_idx on public.payments(booking_id);
create index if not exists payments_order_id_idx on public.payments(order_id);
create index if not exists payments_created_at_idx on public.payments(created_at desc);

update public.bookings set payment_status = case when greatest(coalesce(total_amount,0)-coalesce(discount_amount,0)-coalesce(paid_amount,0),0)=0 then 'оплачено' when coalesce(paid_amount,0)>0 then 'частично' else 'не оплачено' end;
update public.orders set payment_status = case when greatest(coalesce(total_amount,0)-coalesce(discount_amount,0)-coalesce(paid_amount,0),0)=0 then 'оплачено' when coalesce(paid_amount,0)>0 then 'частично' else 'не оплачено' end;

alter table public.payments enable row level security;
drop policy if exists "payments_select_admin" on public.payments;
drop policy if exists "payments_insert_admin" on public.payments;
create policy "payments_select_admin" on public.payments for select to authenticated using (auth.email()='serzh.xz@mail.ru');
create policy "payments_insert_admin" on public.payments for insert to authenticated with check (auth.email()='serzh.xz@mail.ru');

create or replace function public.record_payment(p_booking_id uuid default null,p_order_id uuid default null,p_amount integer default 0,p_payment_method text default 'Перевод',p_note text default null)
returns jsonb language plpgsql security definer set search_path=public as $$
declare v_total integer; v_discount integer; v_paid integer; v_due integer; v_new_paid integer; v_status text; v_payment_id uuid;
begin
if auth.email()<>'serzh.xz@mail.ru' then raise exception 'Доступ запрещён'; end if;
if (p_booking_id is null)=(p_order_id is null) then raise exception 'Нужно указать booking_id или order_id'; end if;
if coalesce(p_amount,0)<=0 then raise exception 'Сумма оплаты должна быть больше нуля'; end if;
if p_booking_id is not null then
 select total_amount,coalesce(discount_amount,0),coalesce(paid_amount,0) into v_total,v_discount,v_paid from public.bookings where id=p_booking_id for update;
 if not found then raise exception 'Бронирование не найдено'; end if;
else
 select total_amount,coalesce(discount_amount,0),coalesce(paid_amount,0) into v_total,v_discount,v_paid from public.orders where id=p_order_id for update;
 if not found then raise exception 'Заказ не найден'; end if;
end if;
v_due=greatest(coalesce(v_total,0)-v_discount-v_paid,0);
if p_amount>v_due then raise exception 'Сумма оплаты больше текущего долга'; end if;
insert into public.payments(booking_id,order_id,amount,payment_method,note,created_by) values(p_booking_id,p_order_id,p_amount,coalesce(nullif(p_payment_method,''),'Перевод'),p_note,auth.uid()) returning id into v_payment_id;
v_new_paid=v_paid+p_amount;
v_status=case when greatest(coalesce(v_total,0)-v_discount-v_new_paid,0)=0 then 'оплачено' when v_new_paid>0 then 'частично' else 'не оплачено' end;
if p_booking_id is not null then update public.bookings set paid_amount=v_new_paid,payment_status=v_status,payment_method=coalesce(nullif(p_payment_method,''),'Перевод'),updated_at=now() where id=p_booking_id;
else update public.orders set paid_amount=v_new_paid,payment_status=v_status,updated_at=now() where id=p_order_id; end if;
return jsonb_build_object('payment_id',v_payment_id,'paid_amount',v_new_paid,'due_amount',greatest(coalesce(v_total,0)-v_discount-v_new_paid,0),'payment_status',v_status);
end; $$;
grant execute on function public.record_payment(uuid,uuid,integer,text,text) to authenticated;
