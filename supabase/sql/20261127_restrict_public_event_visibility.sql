-- FreeDom: restrict direct public event reads to events intended for the homepage.
-- SOURCE / STAGING REVIEW ONLY. Not applied to the live database.
--
-- The current policy exposes every events row (including inactive and hidden
-- records) and relies on browser-side filtering. The legacy booking-sync.js
-- already filters by these same two flags, so this preserves its visible set.

begin;

drop policy if exists public_read_events on public.events;

create policy public_read_events
on public.events
for select
to anon, authenticated
using (
  is_active is true
  and show_on_home is true
);

-- Keep the intentionally public, filtered homepage event RPC available to visitors,
-- but remove implicit PUBLIC execution and pin its function search path.
alter function public.get_home_events(integer) set search_path = pg_catalog;
revoke all on function public.get_home_events(integer) from public;
grant execute on function public.get_home_events(integer) to anon, authenticated, service_role;

commit;
