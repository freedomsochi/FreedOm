-- Remove the unnecessary anonymous grant from the financial summary view.
-- The view is security_invoker=true and reads protected user/finance tables.
-- Source-only patch: test in staging before production approval.
do $$
begin
  if not exists (
    select 1 from pg_catalog.pg_class c
    join pg_catalog.pg_namespace n on n.oid=c.relnamespace
    where n.nspname='public' and c.relname='user_financial_summary'
      and c.relkind='v'
      and coalesce(c.reloptions, array[]::text[]) @> array['security_invoker=true']
  ) then
    raise exception 'Expected security-invoker view public.user_financial_summary not found';
  end if;
  execute 'revoke all privileges on table public.user_financial_summary from anon';
end
$$;
