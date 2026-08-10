-- FreeDom / Veg-raw: таблица заказов кухни
-- Выполнить в Supabase SQL Editor один раз.

create extension if not exists pgcrypto;

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  guest_name text not null,
  guest_phone text not null,
  guest_email text,
  items jsonb not null default '[]'::jsonb,
  total_amount numeric(12,2) not null default 0,
  status text not null default 'новый',
  payment_status text not null default 'не выбрано',
  created_at timestamptz not null default now()
);

create index if not exists orders_user_id_idx on public.orders(user_id);
create index if not exists orders_created_at_idx on public.orders(created_at desc);
create index if not exists orders_status_idx on public.orders(status);

alter table public.orders enable row level security;

-- Удаляем только политики этой таблицы, чтобы скрипт можно было запускать повторно.
drop policy if exists "orders_insert_public" on public.orders;
drop policy if exists "orders_select_owner_or_admin" on public.orders;
drop policy if exists "orders_update_admin" on public.orders;

-- Заказ может отправить и авторизованный пользователь, и гость.
create policy "orders_insert_public"
on public.orders for insert
to anon, authenticated
with check (true);

-- Пользователь видит только свои заказы; администратор видит все.
create policy "orders_select_owner_or_admin"
on public.orders for select
to authenticated
using (
  user_id = auth.uid()
  or auth.email() = 'serzh.xz@mail.ru'
);

-- Администратор может менять статус заказа из админки.
create policy "orders_update_admin"
on public.orders for update
to authenticated
using (auth.email() = 'serzh.xz@mail.ru')
with check (auth.email() = 'serzh.xz@mail.ru');
