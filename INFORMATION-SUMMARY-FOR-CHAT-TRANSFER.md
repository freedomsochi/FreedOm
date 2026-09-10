# FreeDom Sochi — Information Summary for Chat Transfer

> Living project state. Read first in a new chat, then verify GitHub before making changes.

## Core concept
FreeDom is a living house/space, not a conventional hotel/hostel website. It combines accommodation, nature, communication, friendship, creativity, sport, self-development, events, sauna, kitchen, communal life and freedom from imposed social roles.

Core phrase: **«FreeDom — дом в котором есть жизнь.»**

The homepage should feel like looking inside a living world, not a catalog, SaaS dashboard, game menu, cyberpunk interface, spaceship or sterile luxury hotel.

## Final Homepage / Orbit architecture — CURRENT DECISION
The user explicitly confirmed that the Orbit has **5 rooms/directions**:
1. **Пространство**
2. **Кухня**
3. **Баня**
4. **События**
5. **Комнаты**

Do NOT reduce the Orbit to three directions. This is the latest correction and overrides older notes that proposed 3 main doors.

Personal account is separate, subtle in a corner, and is NOT part of Orbit.

## Meaning of the five directions
- Пространство — the FreeDom house, territory, people, atmosphere, nature and the wider life of the place.
- Кухня — food and everyday communal life.
- Баня — a separate world of rest, warmth, water and conversation.
- События — music, lectures, meditation, sport, cinema, karaoke, meetings, creative activity and shared life.
- Комнаты — where the visitor lives; real rooms, categories and booking/availability.

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

Especially liked concept: enter the photograph and let the selected image become the world.

## Space
Existing cinematic Space must be reused, not recreated. It contains fullscreen scenes, vertical storytelling, real FreeDom content, events, sauna/pool/star scene, galleries and mobile adaptation.

Important current discrepancy: on `feat/live-availability-bridge`, `space-preview.html` is currently a redirect to an older Vercel deployment. The fuller Space implementation exists on `main`. Integration should eventually use the real project Space reliably rather than depending on an external redirect.

## Rooms
Use existing real room categories/data and preserve booking/availability logic. Known project categories include family room, double room with balcony, attic room, bungalow, sleeping place on balcony, standard hostel and economy hostel. Verify actual data before changing.

## Kitchen
Separate Orbit direction. It should feel communal/home-like, not like a restaurant. Preserve existing kitchen/order/backend logic.

## Sauna / Events
Both are now confirmed as separate Orbit directions, not hidden under Space.
- Sauna: wood, steam, water, hot/cold contrast, rest, conversation and silence.
- Events: music, lectures, meditation, sport, cinema, karaoke, meetings, bonfire, shared work, birthdays and creative life.

## Backend safety
Repository: `freedomsochi/FreedOm`
Supabase: `vutmbhsclmcfqqlzxqkc`

Do not break Auth, users/guests, rooms, bookings/availability, kitchen/orders, admin/dashboard, notifications, RLS, RPC/business logic or existing Space.

## GitHub state — verified during current work
### `main`
Previously verified HEAD: `c84c8604eb1659b6e91fd021aa44c6ed421b28c6` (`Use atomic public booking RPC for room reservations`).

The persistent summary file is present on `main` at:
`INFORMATION-SUMMARY-FOR-CHAT-TRANSFER.md`

Its current blob SHA before this update was `e71963c8f7ef62744984477db7a5731c80b27381`.

### `feat/live-availability-bridge`
Current HEAD verified during this work before V12 creation:
`21b874ec8dacc1ce3022179ed9c4b362ab0fc07d`
Commit: `feat: build five-branch FreeDom Orbit homepage`
Parent: `41bd79559f48201a32c3c60fecef14e790586f60`

After the current V12 change, this branch advances with the new V12 file; verify its exact tip again before the next implementation sprint.

## Current V11
`freedom-orbit-v11.html` exists on `feat/live-availability-bridge`.
It has five nodes, real branches/photos, physical angle rotation, inertia/snap, upright labels, warm glassmorphism, atmosphere changes, separate account UI and fullscreen world layer.

The tree center is currently softened with a CSS radial mask. This is a temporary visual treatment; do not remove or replace the real branches asset.

## Current V12 — NEWEST IMPLEMENTATION
Created during the current chat on `feat/live-availability-bridge`:
`freedom-orbit-v12.html`

Commit returned by GitHub: `103e50a0e7dfb71ee4a71aac9d0754c196a4ee0a`.

V12 changes:
- keeps **five** Orbit directions;
- uses the user-confirmed order: Пространство / Кухня / Баня / События / Комнаты;
- preserves angle-based rotation, inertia, snap and upright labels;
- preserves real `branches.png` and real FreeDom photos;
- keeps personal account outside Orbit;
- makes the World layer truly fullscreen rather than an inset rounded sheet;
- makes the entry transition more cinematic with scale/opacity and atmospheric fade;
- keeps Space as the first connected world through the existing `space-preview.html` bridge;
- keeps other four worlds as visual placeholders for later connection to existing project data/logic.

V12 is still a prototype. Do not call it production-ready. It needs browser/mobile visual verification before further refinement.

## Orbit history
V5: `933b8c0186a15608ae476f0cbd93037f48ba1fb9` — real tree/photos, glassmorphism, physical rotation, inertia/snap, Space.
V6: `24650bc7a46f6f4e2c7bd6b027608963142c63e5` — biophilic glass interface, transparency, blur, reflections, sunlight, depth, atmospheric reaction.
V7–V10: further experiments; V10 is effectively a wrapper around V9. Do not assume latest version is automatically best.
V11: `21b874ec...` — five-branch homepage prototype.
V12: `103e50a...` — current five-direction prototype with fullscreen world layer.

## Vercel
Vercel project: `freed-om`, connected to `freedomsochi/FreedOm`.
A recent Vercel API deployment listing returned 403 Not Authorized, so deployment state must be freshly verified before claims about current production/preview.

Do not deploy experimental homepage changes to production/main until the Home → World → Home cycle is visually and functionally validated, especially on mobile.

## Visual source
`Фридом pdf (1).pdf` contains 53 pages of real FreeDom visual material: wood interiors, brick, greenery, pool, garden, balconies, rooms, attic, fireplace, sauna, people, shared meals, events, meditation, music, tea ceremony and territory.

## Current task / next steps
Continue from V12; do not restart.
1. Visually inspect V12 on desktop and phone.
2. Refine the tree/Orbit composition and solve the center rectangle through correct alpha/rendering, not by removing branches.
3. Perfect Home → Space transition.
4. Make Space → Home return restore Orbit position.
5. Then connect Kitchen, Sauna, Events and Rooms one by one to existing project logic/data.
6. Only after testing consider replacing `main/index.html` or production deployment.

## Non-negotiables
- Do not endlessly create versions without a concrete improvement.
- Do not rewrite working CRM/backend for visual convenience.
- Do not merge experimental work into `main` until tested.
- Do not invent content/data when existing project data exists.
- Phone is a primary scenario; do not merely shrink desktop.
- Preserve real tree, real photos, warm glassmorphism, physical Orbit, atmospheric transitions, fullscreen worlds and enter/return metaphor.

## Chat-transfer rule
Update this file approximately every **5 working messages**, especially after meaningful code, architecture or deployment changes. If exact automatic timing is impossible, update at the next practical checkpoint and record the latest state.

## Important correction history
A previous summary incorrectly stated that the final architecture was three directions. The user corrected this in the current chat: **the final Orbit has five rooms/directions — Пространство, Кухня, Баня, События, Комнаты.** That correction is authoritative.

## Final metaphor
**One living house, not a collection of unrelated pages.**

- Homepage = entrance.
- Orbit = path.
- Each of the five directions = a door into a part of FreeDom life.
- Account = tool.

The interface should not say “Here are our sections.”
It should visually communicate:

**«Вот FreeDom. Куда хочешь пойти?»**
