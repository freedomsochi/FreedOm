# Public website flows and database access review

Date: 2026-11-27  
Branch: `fix/security-rpc-hardening-2026-11-26`  
Scope: read-only inspection of live Supabase function definitions, table ACL/RLS policies, and repository call sites. No production changes were made.

## Executive result

Do not apply a blanket revoke of `anon` table privileges. Public website flows use a mix of public RPCs and direct Data API reads. The inspected database currently has a narrower effective policy boundary than its table grants suggest, but there are two concrete integration/security issues to resolve before changing grants:

1. The legacy `booking-sync.js` reads `rooms` directly with the publishable key, while live table ACLs deny `anon SELECT` on `rooms`. Its room lookup will fail for an anonymous visitor unless that code is not loaded or the visitor has an authenticated session. The same script also reads `events` directly; that path is currently supported by a public SELECT RLS policy.
2. The publicly executable SECURITY DEFINER RPC `create_event_registration` calls `find_user_by_phone(p_phone)` using the caller-supplied phone number and stores the returned `user_id` on the new registration. This is an unverified phone-to-account association. A caller can submit another person's phone number and cause a registration to be attached to that person's account. This is a confirmed authorization/design flaw in the function body, not evidence that the caller can read the account.

## Public call paths found in source

### Room booking

- `booking_form_v2.html` sends POST `/api/booking`.
- `api/booking.js` forwards the payload to Edge Function `create-public-booking` without a Supabase client-side table write.
- Live RPC `create_public_booking(uuid,date,date,integer,text,text,text,boolean)` is SECURITY DEFINER and inserts into `bookings` after validating room, dates, guest count, availability and family-room extra-bed rules.
- `booking-sync.js` is a separate/legacy client-side path: it calls `sb.from('rooms').select('id,name,price_per_night')`, then `sb.rpc('create_public_booking', ...)`. Its room SELECT is incompatible with current anonymous table privileges on `rooms`.
- `room-booking-form.html` submits directly to Formspree and does not write to Supabase.
- `rooms-catalog.js` calls `get_rooms_catalog()`. The live function is SECURITY INVOKER, but `anon` has no SELECT privilege on `rooms`; therefore the function cannot return rows to an anonymous caller under the inspected ACLs. The separate `get_public_rooms()` function is SECURITY DEFINER and returns only `id,name,description,capacity,booking_mode,image_url`.

### Public events

- `booking-sync.js` reads `events` directly using `sb.from('events').select(...)`, filtering active and homepage-visible events.
- The live `events` table has a public SELECT policy (`public_read_events`, roles `anon,authenticated`, predicate `true`). This currently permits reading all rows allowed by the policy, not just active/homepage-visible rows. The frontend filters its own result; that is not an access-control boundary.
- Registration uses `sb.rpc('create_event_registration', ...)`.
- Live `create_event_registration(uuid,text,text,text,integer,text)` is SECURITY DEFINER and is executable by PUBLIC/anon/authenticated. It checks that the event is active and shown on home, normalizes the phone, calls `find_user_by_phone`, and inserts a registration.
- A second flaw was found in the table trigger `attach_event_user_by_phone()`: even if the RPC stops resolving accounts by phone, the BEFORE INSERT/UPDATE trigger independently calls `find_user_by_phone(new.guest_phone)` and can reattach an unverified account. Both layers must be fixed together.
- Source-only hardening is now prepared in `supabase/sql/20261127_harden_public_event_registration.sql` with companion verification SQL. It validates name/phone/participants/field lengths/amount, links only `auth.uid()` with a matching verified Auth phone, replaces the trigger's unsafe lookup, fixes search paths, and removes the implicit PUBLIC EXECUTE grant while preserving anon/authenticated access. Neither SQL file has been applied to the live database.

### Availability and public room data

- `api/availability.js` forwards to Edge Function `public-availability`.
- The inspected public availability SQL functions are SECURITY DEFINER and query `rooms` and `bookings` internally; the caller does not need direct SELECT on those base tables.
- `get_public_rooms()` is SECURITY DEFINER and exposes a limited public room projection.
- `get_rooms_catalog()` is SECURITY INVOKER, despite having EXECUTE for anon/authenticated. It selects `price_per_night` from `rooms`, but anonymous callers have no SELECT privilege on `rooms`. This is an inconsistent public API contract.
- The room table schema confirms the seven catalog fields (`id,name,description,price_per_night,capacity,image_url,booking_mode`) exist. A source-only patch is prepared in `supabase/sql/20261127_harden_public_room_catalog.sql`: it preserves the exact frontend return contract, uses a fixed `pg_catalog` search path, exposes only those seven fields, and removes implicit PUBLIC EXECUTE. Companion verification SQL is included. Not applied to the live database.

## Live table ACL and RLS snapshot

RLS is enabled on all inspected tables.

| Table | anon SELECT | anon INSERT | authenticated SELECT | authenticated INSERT |
|---|---:|---:|---:|---:|
| rooms | no | no | no | no |
| bookings | no | no | no | no |
| events | yes | yes | yes | yes |
| event_registrations | yes | yes | yes | yes |
| orders | yes | yes | yes | yes |
| service_orders | yes | yes | yes | yes |
| payments | yes | yes | yes | yes |
| payment_allocations | yes | yes | yes | yes |

The broad table-level INSERT/SELECT grants on sensitive tables do not by themselves prove anonymous access: inspected RLS policies on `event_registrations`, `orders`, `service_orders`, `payments`, and `payment_allocations` are authenticated fixed-owner-email policies, with no anon policy returned for those tables. The event table does have a public SELECT policy. Keep grants and policies distinct in the review.

### Additional admin RPC finding

- `confirm_public_booking(uuid)` is SECURITY DEFINER and currently has anon EXECUTE even though its function body immediately rejects callers unless the JWT email matches the administrator address. No direct frontend caller was found in the inspected source search. A source-only ACL patch is prepared in `supabase/sql/20261127_restrict_public_booking_confirmation.sql`: revoke anon and implicit PUBLIC execution, preserve authenticated/service_role, and pin `search_path` to `pg_catalog`. Companion verification SQL is included. Not applied to live DB.

## Recommended changes — source/staging only

1. **Fix event registration identity association first.** Source patch prepared for both the RPC and its BEFORE trigger; it prevents unverified phone-based account linking and adds validation. Still requires isolated staging tests, including anon and verified-auth identities, before any production release. Rate limiting/anti-abuse remains a separate follow-up.
2. **Narrow event public reads.** Prepared a staging-only RLS policy matching the existing legacy client's active/homepage-visible filter, plus explicit grants and fixed search path for `get_home_events`. This narrows rows but still exposes all columns of visible events; a separate public projection may be preferable if fields become sensitive.
3. **Resolve room catalog contract.** A narrow `get_rooms_catalog()` SECURITY DEFINER projection is prepared with the exact seven fields used by `rooms-catalog.js`; test anonymous execution in staging. Do not grant anon broad SELECT on `rooms` just to make the legacy script work.
4. **Retire or repair legacy `booking-sync.js` path.** It directly queries `rooms` and `events`; verify whether any deployed page loads it before changing its behavior or table grants. The newer `booking_form_v2.html` → API → Edge → RPC path does not require browser-side SELECT on `rooms`.
5. **Reduce unnecessary table privileges after call-site verification.** For tables only touched inside SECURITY DEFINER RPCs or server-side functions, revoke direct anon/authenticated grants only in a reviewed migration with explicit tests. Keep public RPC EXECUTE grants intentional and audited.

## Verification still required before a migration

- Enumerate deployed HTML entry points that load `booking-sync.js` and `rooms-catalog.js`; repository presence alone does not prove runtime use.
- Test anonymous execution of the patched `get_rooms_catalog()` against staging/test data and verify exactly seven public fields.
- Test anon direct SELECT returns only active/homepage-visible event rows; confirm inactive and hidden rows are not visible.
- Test `get_home_events(integer)` remains callable by anon/authenticated, returns only future active/homepage-visible rows, and has no implicit PUBLIC EXECUTE.
- Test anon cannot execute `confirm_public_booking(uuid)` while authenticated admin and service_role retain intended execution.
- Test event registration with a phone number belonging to an existing user and verify both RPC and trigger leave `user_id` NULL without verified authentication; verify matching verified `auth.uid()` is linked.
- Re-run grants, policies, function ACL, and Supabase Security Advisor after any staged change.

## Safety

This is an audit artifact only. No grants, policies, functions, data, bookings, payments, or deployments were changed.
