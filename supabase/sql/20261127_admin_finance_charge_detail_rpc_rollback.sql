-- Manual rollback for admin_get_finance_charge_detail(text,uuid).
-- Restore the previous admin_v11_finance_detail.html only after reviewing the
-- resulting direct-table-read dependency and confirming a safe release plan.
revoke all on function public.admin_get_finance_charge_detail(text,uuid) from public, anon, authenticated;
drop function if exists public.admin_get_finance_charge_detail(text,uuid);
