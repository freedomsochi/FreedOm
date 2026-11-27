-- SOURCE-ONLY STAGING MIGRATION. Requires private.has_admin_role().
-- Adds the minimal guest identity projection to the protected finance overview
-- so the browser no longer reads public.users directly.
begin;

do $preflight$
begin
  if to_regprocedure('private.has_admin_role()') is null then
    raise exception 'Missing private.has_admin_role(); apply and validate admin-role-foundation.sql in staging first';
  end if;
  if exists (
    select 1 from pg_proc h
    where h.oid='private.has_admin_role()'::regprocedure
      and h.proowner <> (select oid from pg_roles where rolname=current_user)
  ) then
    raise exception 'Migration role must own the admin role helper';
  end if;
  if to_regclass('public.user_financial_summary') is null
     or to_regclass('public.user_financial_breakdown') is null then
    raise exception 'Expected finance summary views are missing';
  end if;
end
$preflight$;

create or replace function public.admin_get_finance_overview()
returns jsonb
language plpgsql
stable
security definer
set search_path = pg_catalog
as $function$
declare
  v_summary jsonb;
  v_breakdown jsonb;
  v_payments jsonb;
  v_users jsonb;
begin
  if auth.uid() is null or not private.has_admin_role() then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(to_jsonb(s)), '[]'::jsonb)
    into v_summary
  from public.user_financial_summary s;

  select coalesce(jsonb_agg(to_jsonb(f) order by f.created_at desc), '[]'::jsonb)
    into v_breakdown
  from public.user_financial_breakdown f;

  select coalesce(jsonb_agg(to_jsonb(p) order by p.created_at desc), '[]'::jsonb)
    into v_payments
  from (
    select p.*, coalesce(p.user_id,b.user_id,o.user_id) as effective_user_id
    from public.payments p
    left join public.bookings b on b.id=p.booking_id
    left join public.orders o on o.id=p.order_id
    order by p.created_at desc
    limit 500
  ) p;

  select coalesce(jsonb_agg(jsonb_build_object(
    'user_id', u.user_id,
    'Display_name', u."Display_name",
    'Phone', u."Phone",
    'Email', u."Email"
  )), '[]'::jsonb)
    into v_users
  from public.users u
  where exists (
    select 1 from public.user_financial_summary s
    where s.user_id=u.user_id
  );

  return jsonb_build_object(
    'summary',v_summary,
    'breakdown',v_breakdown,
    'payments',v_payments,
    'users',v_users
  );
end
$function$;

revoke all on function public.admin_get_finance_overview() from public, anon, authenticated;
grant execute on function public.admin_get_finance_overview() to authenticated;

commit;
