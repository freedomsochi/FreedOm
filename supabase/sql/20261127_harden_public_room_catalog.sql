-- FreeDom: make the public room catalog RPC match the actual public UI contract.
-- SOURCE / STAGING REVIEW ONLY. Not applied to the live database.
--
-- The frontend expects price_per_night, but the current SECURITY INVOKER
-- function selects from rooms while anon has no usable SELECT policy/grant.
-- This function exposes only the seven fields consumed by rooms-catalog.js.

begin;

create or replace function public.get_rooms_catalog()
returns table (
  id uuid,
  name text,
  description text,
  price_per_night integer,
  capacity integer,
  image_url text,
  booking_mode text
)
language sql
stable
security definer
set search_path = pg_catalog
as $function$
  select
    r.id,
    r.name,
    r.description,
    r.price_per_night,
    r.capacity,
    r.image_url,
    r.booking_mode
  from public.rooms r
  order by r.name;
$function$;

revoke all on function public.get_rooms_catalog() from public;
grant execute on function public.get_rooms_catalog() to anon, authenticated, service_role;

commit;
