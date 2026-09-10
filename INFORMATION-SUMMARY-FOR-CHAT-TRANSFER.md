# FreeDom Sochi — Information Summary for Chat Transfer

## Core concept
FreeDom is a living house/space, not a conventional hotel/hostel website. It combines accommodation, nature, communication, friendship, creativity, sport, self-development, events, sauna, kitchen, communal life and freedom from imposed social roles.

Core phrase: **«FreeDom — дом в котором есть жизнь.»**

## Final Orbit architecture
The Orbit has **5 directions**, confirmed by the user:
1. Пространство
2. Кухня
3. Баня
4. События
5. Комнаты

Personal account is a separate subtle element in a corner and is not part of Orbit.

## Visual principles
- Real FreeDom photos only; no random stock imagery.
- Keep the real `images/branches.png` tree/branches asset.
- Warm organic glassmorphism: wood, red brick, greenery, water, soft sunlight, transparent glass, blur and depth.
- Modern technology is acceptable only while preserving the feeling of a living home.
- Idle state should subtly live: light, leaves, reflections and depth.
- No cold sci-fi, cyberpunk, spaceship, game UI or sterile luxury hotel aesthetic.

## Orbit interaction
Preserve the strongest mechanics from V5–V11:
- pointer/finger angle-based rotation;
- drag + inertia;
- smooth slowdown;
- nearest-item snap;
- upright/readable labels;
- atmospheric background changes;
- selected item becomes more material/brighter without aggressive glow;
- selection feels like entering a door, not a giant CTA.

## World transition
Desired cycle:
Home → select direction → atmosphere changes → Orbit dissolves → selected world becomes fullscreen → internal interaction/scroll → world dissolves → Home returns → previous Orbit position is restored.

## Space
Existing cinematic Space must be reused, not recreated. It contains fullscreen scenes, vertical storytelling, real FreeDom content, events, sauna/pool/star scene, galleries and mobile adaptation.

Important current discrepancy: on `feat/live-availability-bridge`, `space-preview.html` is only a redirect to an older Vercel deployment. The fuller Space implementation exists on `main`. Integration should eventually use the real project Space reliably rather than depending on an external redirect.

## Rooms
Use existing real room categories/data and preserve booking/availability logic. Known project categories include family room, double room with balcony, attic room, bungalow, sleeping place on balcony, standard hostel and economy hostel. Verify actual data before changing.

## Kitchen
Separate Orbit direction. It should feel communal/home-like, not like a restaurant. Preserve existing kitchen/order/backend logic.

## Sauna / Events
Both remain separate Orbit directions.
- Sauna: wood, steam, water, hot/cold contrast, rest, conversation and silence.
- Events: music, lectures, meditation, sport, cinema, karaoke, meetings, bonfire, shared work, birthdays and creative life.

## Backend safety
Repository: `freedomsochi/FreedOm`
Supabase: `vutmbhsclmcfqqlzxqkc`

Do not break Auth, users/guests, rooms, bookings/availability, kitchen/orders, admin/dashboard, notifications, RLS, RPC/business logic or existing Space.

## GitHub state last verified 2026-09-10
### main
HEAD before this documentation commit: `c84c8604eb1659b6e91fd021aa44c6ed421b28c6`
Commit: `Use atomic public booking RPC for room reservations`

A documentation commit was created from that tree as `097fb3e3543f9b3a9907ff6acda8843e64c60e91`, but the connector did not permit moving the existing `main` ref with the create-branch action. Verify/refine the final placement before claiming the file is on main.

### feat/live-availability-bridge
HEAD verified on 2026-09-10:
`21b874ec8dacc1ce3022179ed9c4b362ab0fc07d`
Commit: `feat: build five-branch FreeDom Orbit homepage`
Parent: `41bd79559f48201a32c3c60fecef14e790586f60`

## Current V11
`freedom-orbit-v11.html` exists on `feat/live-availability-bridge`.
It currently has five nodes: Пространство, События, Комнаты, Баня, Кухня; real branches/photos; physical angle rotation; inertia/snap; upright labels; warm glassmorphism; atmosphere changes; separate account UI; fullscreen world layer; Space entry through `space-preview.html`.

The tree center is currently softened with a CSS radial mask. This is only a temporary visual treatment; do not remove or replace the real branches asset.

## Orbit history
V5: `933b8c0186a15608ae476f0cbd93037f48ba1fb9` — real tree/photos, glassmorphism, physical rotation, inertia/snap, Space.
V6: `24650bc7a46f6f4e2c7bd6b027608963142c63e5` — biophilic glass interface, transparency, blur, reflections, sunlight, depth, atmospheric reaction.
V7–V10: further experiments; V10 is effectively a wrapper around V9. Do not assume latest version is automatically best.
V11: `21b874ec...` — five-branch homepage prototype.

## Vercel
Vercel project: `freed-om`, connected to `freedomsochi/FreedOm`. A recent Vercel API deployment listing returned 403 Not Authorized, so deployment state must be freshly verified before claims about current production/preview.

## Visual source
`Фридом pdf (1).pdf` contains 53 pages of real FreeDom visual material: wood interiors, brick, greenery, pool, garden, balconies, rooms, attic, fireplace, sauna, people, shared meals, events, meditation, music, tea ceremony and territory. Prefer these real materials over stock imagery.

## Current task / next steps
Continue from V11; do not restart.
1. Preserve five Orbit directions.
2. Improve homepage composition and tree/Orbit visual quality.
3. Perfect Home → Space transition.
4. Reuse real existing Space.
5. Make Space → Home return restore Orbit state.
6. Then connect Kitchen, Sauna, Events and Rooms to existing project logic/data.
7. Test mobile before considering production/main.

## Non-negotiables
- Do not endlessly create versions without purpose.
- Do not rewrite working CRM/backend for visual convenience.
- Do not merge experimental work into `main` until tested.
- Do not invent content/data when existing project data exists.
- Phone is a primary scenario; do not merely shrink desktop.
- Preserve real tree, real photos, warm glassmorphism, physical Orbit, atmospheric transitions, fullscreen worlds and enter/return metaphor.

## Chat-transfer rule
Update this file approximately every **5 working messages**, especially after meaningful code, architecture or deployment changes. If exact automatic timing is impossible, update at the next practical checkpoint and record the latest state.

## Last user correction
The user explicitly confirmed: **five rooms/directions — Пространство, Кухня, Баня, События, Комнаты.**
