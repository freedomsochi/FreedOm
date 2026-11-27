-- Manual STAGING rollback for public.admin_get_finance_overview().
-- Restores the exact pre-migration live definition captured on 2026-11-27.
-- This intentionally restores the legacy fixed-email guard and search_path=public;
-- use only as an emergency staging rollback, never as a preferred production state.
begin;

create or replace function public.admin_get_finance_overview()
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_email text;
  v_summary jsonb;
  v_breakdown jsonb;
  v_payments jsonb;
begin
  v_email := auth.email();
  if v_email is null or v_email <> 'serzh.xz@mail.ru' then
    raise exception 'not authorized';
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
    select p.*,
           coalesce(p.user_id,b.user_id,o.user_id) as effective_user_id
    from public.payments p
    left join public.bookings b on b.id=p.booking_id
    left join public.orders o on o.id=p.order_id
    order by p.created_at desc
    limit 500
  ) p;

  return jsonb_build_object(
    'summary',v_summary,
    'breakdown',v_breakdown,
    'payments',v_payments
  );
end;
$function$;

revoke all on function public.admin_get_finance_overview() from public, anon, authenticated, service_role;
grant execute on function public.admin_get_finance_overview() to authenticated, service_role;

commit;
