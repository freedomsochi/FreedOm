-- SOURCE-ONLY staging migration. Depends on supabase/sql/admin-role-foundation.sql.
-- One authenticated admin endpoint replaces broad browser reads of events and registrations.
begin;

do $preflight$
begin
  if to_regprocedure('private.has_admin_role()') is null then
    raise exception 'Missing prerequisite private.has_admin_role(); apply and validate admin-role-foundation.sql in staging first';
  end if;
  if exists (
    select 1 from pg_proc h
    where h.oid='private.has_admin_role()'::regprocedure
      and h.proowner <> (select oid from pg_roles where rolname=current_user)
  ) then
    raise exception 'Migration role must own the admin role helper before creating the SECURITY DEFINER endpoint';
  end if;
end
$preflight$;

create or replace function public.admin_get_events_dashboard()
returns jsonb
language plpgsql
stable
security definer
set search_path = pg_catalog
as $function$
declare
  v_result jsonb;
begin
  if auth.uid() is null or not private.has_admin_role() then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;

  select jsonb_build_object(
    'events',
    coalesce((
      select jsonb_agg(to_jsonb(e) order by e.event_date, e.start_time)
      from (
        select id, name, description, event_date, start_time, end_time,
               location, price, image_url, is_active, show_on_home
        from public.events
      ) e
    ), '[]'::jsonb),
    'registrations',
    coalesce((
      select jsonb_agg(to_jsonb(r) order by r.created_at desc)
      from (
        select id, event_id, guest_name, guest_phone, guest_email,
               participants, amount, paid_amount, status, payment_status,
               comment, created_at, user_id
        from public.event_registrations
      ) r
    ), '[]'::jsonb)
  )
  into v_result;

  return v_result;
end
$function$;

revoke all on function public.admin_get_events_dashboard() from public, anon, authenticated;
grant execute on function public.admin_get_events_dashboard() to authenticated;

commit;
