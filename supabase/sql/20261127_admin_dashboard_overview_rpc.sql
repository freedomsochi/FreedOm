-- SOURCE-ONLY STAGING MIGRATION. Requires private.has_owner_role().
begin;
do $preflight$
begin
  if to_regprocedure('private.has_owner_role()') is null then
    raise exception 'Missing private.has_owner_role(); apply and validate admin-role-foundation.sql in staging first';
  end if;
  if exists (select 1 from pg_proc h where h.oid='private.has_owner_role()'::regprocedure
    and h.proowner <> (select oid from pg_roles where rolname=current_user)) then
    raise exception 'Migration role must own the admin role helper';
  end if;
  if to_regclass('public.user_financial_summary') is null then
    raise exception 'Missing public.user_financial_summary';
  end if;
end
$preflight$;

create or replace function public.admin_get_dashboard_overview()
returns jsonb language plpgsql stable security definer
set search_path = pg_catalog
as $function$
declare
  v_guests_count bigint;
  v_active_events_count bigint;
  v_registrations_count bigint;
  v_finance jsonb;
  v_events jsonb;
  v_registrations jsonb;
begin
  if auth.uid() is null or not private.has_owner_role() then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;

  select count(*) into v_guests_count from public.users;
  select count(*) into v_active_events_count from public.events where is_active is true;
  select count(*) into v_registrations_count from public.event_registrations;

  select coalesce(jsonb_agg(jsonb_build_object('user_id',s.user_id,'total_debt',s.total_debt)), '[]'::jsonb)
  into v_finance from public.user_financial_summary s where coalesce(s.total_debt,0)>0;

  select coalesce(jsonb_agg(to_jsonb(e) order by e.event_date,e.start_time),'[]'::jsonb)
  into v_events from (
    select id,name,event_date,start_time,location,price from public.events
    where is_active is true and event_date >= current_date
    order by event_date,start_time limit 5
  ) e;

  select coalesce(jsonb_agg(jsonb_build_object(
    'id',r.id,'guest_name',r.guest_name,'amount',r.amount,'paid_amount',r.paid_amount,
    'status',r.status,'created_at',r.created_at,'event_id',r.event_id,
    'events',case when e.id is null then null else jsonb_build_object('name',e.name,'event_date',e.event_date) end
  ) order by r.created_at desc),'[]'::jsonb)
  into v_registrations
  from (
    select id,guest_name,amount,paid_amount,status,created_at,event_id
    from public.event_registrations order by created_at desc limit 6
  ) r left join public.events e on e.id=r.event_id;

  return jsonb_build_object(
    'guests_count',v_guests_count,'active_events_count',v_active_events_count,
    'registrations_count',v_registrations_count,'finance',v_finance,
    'events',v_events,'registrations',v_registrations
  );
end
$function$;

revoke all on function public.admin_get_dashboard_overview() from public, anon, authenticated;
grant execute on function public.admin_get_dashboard_overview() to authenticated;
commit;
