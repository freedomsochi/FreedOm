-- Source-only hardening for two finance RPCs. Not applied to production.
begin;

create or replace function public.record_payment(
  p_booking_id uuid,
  p_order_id uuid,
  p_amount integer,
  p_payment_method text,
  p_note text
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog
as $function$
declare
  v_user_id uuid;
  v_total integer;
  v_discount integer;
  v_paid integer;
  v_due integer;
  v_new_paid integer;
  v_status text;
  v_payment_id uuid;
  v_method text;
begin
  if auth.uid() is null or auth.email() is distinct from 'serzh.xz@mail.ru' then
    raise exception 'Доступ запрещён' using errcode = '42501';
  end if;
  if (p_booking_id is null) = (p_order_id is null) then
    raise exception 'Нужно указать booking_id или order_id';
  end if;
  if coalesce(p_amount, 0) <= 0 then
    raise exception 'Сумма оплаты должна быть больше нуля';
  end if;

  v_method := coalesce(nullif(pg_catalog.btrim(p_payment_method), ''), 'Перевод');
  if p_booking_id is not null then
    select user_id,total_amount,coalesce(discount_amount,0),coalesce(paid_amount,0)
      into v_user_id,v_total,v_discount,v_paid
      from public.bookings where id=p_booking_id for update;
  else
    select user_id,total_amount,coalesce(discount_amount,0),coalesce(paid_amount,0)
      into v_user_id,v_total,v_discount,v_paid
      from public.orders where id=p_order_id for update;
  end if;
  if v_user_id is null then raise exception 'Запись не найдена или пользователь не указан'; end if;

  v_due := greatest(coalesce(v_total,0)-v_discount-v_paid,0);
  if p_amount > v_due then
    raise exception 'Сумма оплаты (%) больше текущего долга (%)',p_amount,v_due;
  end if;

  insert into public.payments(
    booking_id,order_id,user_id,amount,payment_method,method,note,created_by,status
  )
  values(
    p_booking_id,p_order_id,v_user_id,p_amount,v_method,
    public.payment_method_code(v_method),p_note,auth.uid(),'успешно'
  ) returning id into v_payment_id;

  insert into public.payment_allocations(payment_id,booking_id,order_id,amount)
  values(v_payment_id,p_booking_id,p_order_id,p_amount);

  v_new_paid := v_paid+p_amount;
  v_status := case
    when greatest(coalesce(v_total,0)-v_discount-v_new_paid,0)=0 then 'оплачено'
    when v_new_paid>0 then 'частично' else 'не оплачено'
  end;

  if p_booking_id is not null then
    update public.bookings set paid_amount=v_new_paid,payment_status=v_status,
      payment_method=v_method,updated_at=pg_catalog.now() where id=p_booking_id;
  else
    update public.orders set paid_amount=v_new_paid,payment_status=v_status,
      payment_method=v_method,updated_at=pg_catalog.now() where id=p_order_id;
  end if;

  return jsonb_build_object(
    'payment_id',v_payment_id,'user_id',v_user_id,'paid_amount',v_new_paid,
    'due_amount',greatest(coalesce(v_total,0)-v_discount-v_new_paid,0),
    'payment_status',v_status
  );
end;
$function$;

create or replace function public.record_user_payment(
  p_user_id uuid,
  p_amount integer,
  p_payment_method text,
  p_note text
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog
as $function$
declare
  v_total_debt integer;
  v_remaining integer;
  v_payment_id uuid;
  v_method text;
  v_alloc integer;
  v_new_paid integer;
  r record;
begin
  if auth.uid() is null or auth.email() is distinct from 'serzh.xz@mail.ru' then
    raise exception 'Доступ запрещён' using errcode = '42501';
  end if;
  if p_user_id is null then raise exception 'Не указан пользователь'; end if;
  if coalesce(p_amount,0)<=0 then raise exception 'Сумма оплаты должна быть больше нуля'; end if;

  select total_debt into v_total_debt
    from public.user_financial_summary where user_id=p_user_id;
  if v_total_debt is null then raise exception 'Пользователь не найден'; end if;
  if p_amount>v_total_debt then
    raise exception 'Сумма оплаты (%) больше текущего долга (%)',p_amount,v_total_debt;
  end if;

  v_remaining:=p_amount;
  v_method:=coalesce(nullif(pg_catalog.btrim(p_payment_method),''),'Перевод');
  insert into public.payments(user_id,amount,payment_method,method,note,created_by,status)
  values(p_user_id,p_amount,v_method,public.payment_method_code(v_method),p_note,auth.uid(),'успешно')
  returning id into v_payment_id;

  for r in
    select charge_type,charge_id,due,created_at from (
      select 'booking'::text charge_type,b.id charge_id,
        greatest(coalesce(b.total_amount,0)-coalesce(b.discount_amount,0)-coalesce(b.paid_amount,0),0) due,b.created_at
      from public.bookings b where b.user_id=p_user_id and coalesce(b.status,'') not in ('отменено','отменена','cancelled')
      union all
      select 'order'::text,o.id,
        greatest(coalesce(o.total_amount,0)-coalesce(o.discount_amount,0)-coalesce(o.paid_amount,0),0),o.created_at
      from public.orders o where o.user_id=p_user_id and coalesce(o.status,'') not in ('отменён','отменена','cancelled')
      union all
      select 'service'::text,so.id,
        greatest(coalesce(so.total_amount,0)-coalesce((select sum(pa.amount)
          from public.payment_allocations pa join public.payments p on p.id=pa.payment_id
          where pa.service_order_id=so.id and p.status='успешно'),0),0),so.created_at
      from public.service_orders so where so.user_id=p_user_id and coalesce(so.status,'') not in ('отменён','отменена','cancelled')
      union all
      select 'event'::text,er.id,
        greatest(coalesce(er.amount,0)-coalesce(er.paid_amount,0),0),er.created_at
      from public.event_registrations er where er.user_id=p_user_id and coalesce(er.status,'') not in ('отменено','отменена','cancelled')
    ) q
    where due>0 order by created_at,charge_type,charge_id
  loop
    exit when v_remaining<=0;
    v_alloc:=least(v_remaining,r.due);

    insert into public.payment_allocations(payment_id,booking_id,order_id,service_order_id,event_registration_id,amount)
    values(v_payment_id,
      case when r.charge_type='booking' then r.charge_id end,
      case when r.charge_type='order' then r.charge_id end,
      case when r.charge_type='service' then r.charge_id end,
      case when r.charge_type='event' then r.charge_id end,v_alloc);

    if r.charge_type='booking' then
      select coalesce(paid_amount,0)+v_alloc into v_new_paid
        from public.bookings where id=r.charge_id for update;
      update public.bookings set paid_amount=v_new_paid,
        payment_status=case when greatest(coalesce(total_amount,0)-coalesce(discount_amount,0)-v_new_paid,0)=0 then 'оплачено' when v_new_paid>0 then 'частично' else 'не оплачено' end,
        payment_method=v_method,updated_at=pg_catalog.now() where id=r.charge_id;
    elsif r.charge_type='order' then
      select coalesce(paid_amount,0)+v_alloc into v_new_paid
        from public.orders where id=r.charge_id for update;
      update public.orders set paid_amount=v_new_paid,
        payment_status=case when greatest(coalesce(total_amount,0)-coalesce(discount_amount,0)-v_new_paid,0)=0 then 'оплачено' when v_new_paid>0 then 'частично' else 'не оплачено' end,
        updated_at=pg_catalog.now() where id=r.charge_id;
    elsif r.charge_type='event' then
      select coalesce(paid_amount,0)+v_alloc into v_new_paid
        from public.event_registrations where id=r.charge_id for update;
      update public.event_registrations set paid_amount=v_new_paid,
        payment_status=case when v_new_paid>=coalesce(amount,0) then 'paid' when v_new_paid>0 then 'partial' else coalesce(payment_status,'unpaid') end,
        updated_at=pg_catalog.now() where id=r.charge_id;
    end if;
    v_remaining:=v_remaining-v_alloc;
  end loop;

  if v_remaining>0 then raise exception 'Не удалось распределить оплату по задолженностям'; end if;
  return jsonb_build_object('ok',true,'payment_id',v_payment_id,'paid_amount',p_amount,'due_amount',v_total_debt-p_amount);
end;
$function$;

revoke all on function public.record_payment(uuid,uuid,integer,text,text) from public;
revoke all on function public.record_payment(uuid,uuid,integer,text,text) from anon;
grant execute on function public.record_payment(uuid,uuid,integer,text,text) to authenticated, service_role;

revoke all on function public.record_user_payment(uuid,integer,text,text) from public;
revoke all on function public.record_user_payment(uuid,integer,text,text) from anon;
grant execute on function public.record_user_payment(uuid,integer,text,text) to authenticated, service_role;
commit;
