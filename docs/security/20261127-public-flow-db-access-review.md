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
- The registration RPC does not enforce a non-empty guest name or a practical upper bound for `p_participants`; it only coerces the lower bound to at least 1. This should be tightened with input validation.

### Availability and public room data

- `api/availability.js` forwards to Edge Function `public-availability`.
- The inspected public availability SQL functions are SECURITY DEFINER and query `rooms` and `bookings` internally; the caller does not need direct SELECT on those base tables.
- `get_public_rooms()` is SECURITY DEFINER and exposes a limited public room projection.
- `get_rooms_catalog()` is SECURITY INVOKER, despite having EXECUTE for anon/authenticated. It selects `price_per_night` from `rooms`, but anonymous callers have no SELECT privilege on `rooms`. This is an inconsistent public API contract.

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

## Recommended changes — source/staging only

1. **Fix event registration identity association first.** In the public RPC, do not infer `user_id` from an unverified phone number. Set `user_id := auth.uid()` only for a genuinely authenticated caller, or use a separately verified-contact linking flow. Preserve guest contact fields independently. Add required guest-name validation, participant bounds, sensible field-length limits, and a rate-limit/anti-abuse strategy.
2. **Narrow event public reads.** Replace the broad `public_read_events USING (true)` policy with a public projection/RPC or a predicate that exposes only intended public event fields and active/homepage-visible records. Do not assume the client-side `.eq('is_active', true)` filter protects hidden events.
3. **Resolve room catalog contract.** Prefer a narrow public SECURITY DEFINER projection (similar to `get_public_rooms`) if the site needs anonymous room lookup. Otherwise keep direct table access private and route lookup through that RPC. Do not grant anon broad SELECT on `rooms` just to make the legacy script work.
4. **Retire or repair legacy `booking-sync.js` path.** It directly queries `rooms` and `events`; verify whether any deployed page loads it before changing its behavior or table grants. The newer `booking_form_v2.html` → API → Edge → RPC path does not require browser-side SELECT on `rooms`.
5. **Reduce unnecessary table privileges after call-site verification.** For tables only touched inside SECURITY DEFINER RPCs or server-side functions, revoke direct anon/authenticated grants only in a reviewed migration with explicit tests. Keep public RPC EXECUTE grants intentional and audited.

## Verification still required before a migration

- Enumerate deployed HTML entry points that load `booking-sync.js` and `rooms-catalog.js`; repository presence alone does not prove runtime use.
- Test anonymous execution of `get_rooms_catalog()` and `get_public_rooms()` against staging/test data.
- Test public event list responses for inactive and non-homepage events.
- Test event registration with a phone number belonging to an existing user and verify that the new row is not linked without verified authentication.
- Re-run grants, policies, function ACL, and Supabase Security Advisor after any staged change.

## Safety

This is an audit artifact only. No grants, policies, functions, data, bookings, payments, or deployments were changed.
