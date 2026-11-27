-- Staging rollback for the finance overview payload extension.
-- IMPORTANT: This restores the pre-extension response shape but PRESERVES the
-- owner-role guard and fixed pg_catalog search_path installed by the prerequisite
-- 12-RPC hardening migration. It does not restore the legacy fixed-email guard.
begin;

create or replace function public.admin_get_finance_overview()
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog
as $function$
declare
  v_email text;
  v_summary jsonb;
  v_breakdown jsonb;
  v_payments jsonb;
begin
  if auth.uid() is null or not private.has_owner_role() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(to_jsonb(s)),'[]'::jsonb)
    into v_summary
  from public.user_financial_summary s;

  select coalesce(jsonb_agg(to_jsonb(f) order by f.created_at desc),'[]'::jsonb)
    into v_breakdown
  from public.user_financial_breakdown f;

  select coalesce(jsonb_agg(to_jsonb(p) order by p.created_at desc),'[]'::jsonb)
    into v_payments
  from (
    select p.*,coalesce(p.user_id,b.user_id,o.user_id) effective_user_id
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

revoke all on function public.admin_get_finance_overview() from public, anon;
grant execute on function public.admin_get_finance_overview() to authenticated;

commit;
