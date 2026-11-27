-- FreeDom: remove anonymous execution from the admin-only public-booking confirmation RPC.
-- SOURCE / STAGING REVIEW ONLY. Not applied to the live database.
--
-- The function body already requires the fixed administrator email, so anon
-- callers can never succeed. Keep it authenticated-only and pin search_path.

begin;

alter function public.confirm_public_booking(uuid) set search_path = pg_catalog;
revoke all on function public.confirm_public_booking(uuid) from public;
revoke execute on function public.confirm_public_booking(uuid) from anon;
grant execute on function public.confirm_public_booking(uuid) to authenticated, service_role;

commit;
