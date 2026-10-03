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

The Rooms branch is now being redesigned as an interactive 3D spatial model rather than a flat floor-plan/card catalog.

### Approved Rooms visual direction — 2026-10-04
The user approved the cinematic top-down/isometric reference generated for the Rooms page. Important: the generated image is a **visual quality and UI reference**, NOT the exact architectural geometry.

Desired experience:
- professionally designed 3D environment;
- top-down/isometric view similar to a modern digital map/virtual tour;
- user can pan, zoom and rotate the model;
- default view shows the whole territory and house;
- left navigation contains «Пространство» plus floors: Мансарда, 3 этаж, 2 этаж, 1 этаж, −1 этаж;
- selecting a floor moves the camera toward the house and visually emphasizes that level while other levels become dimmer;
- selecting «Пространство» keeps the whole territory visible;
- territory objects have subtle glowing points/hotspots;
- selecting an object animates the camera from above toward it;
- information card appears only after selection/approach, not permanently below the map;
- card contains photo, description, capacity, booking mode, availability/price when authoritative and «Забронировать»;
- dark cinematic UI, warm architectural light, vegetation, water and depth;
- approved lower-right handwritten phrase: **«Здесь начинается твоя история...»**;
- approved interface elements include return-to-home, left floor navigation and light/dark toggle.

### Spatial layout correction
The generated reference image is NOT geometrically accurate. The real model must follow the established FreeDom textual plan:
- gates at the bottom;
- route from gates toward the house;
- house central;
- porch on the right side of the house;
- road/path down toward the training/sport zone;
- swimming pool to the right of that route;
- summer kitchen adjacent to the house in its known position;
- garden/territory around the house;
- bungalow, hammock and fountain in the territory according to the known plan.

The house must preserve the established level structure: −1, 1, 2, 3, attic, with rooms, common spaces, stairwell and balconies according to the existing textual plan. Exact dimensions are not authoritative until supported by a real architectural plan.

### Rooms 3D implementation artifacts
Main branch documentation:
- `ROOMS_3D_DESIGN_BRIEF.md` — approved 3D visual/interaction brief.
- `ROOMS_SPACE_MODEL_TZ.md` — earlier Rooms UX/architecture specification; use together with the new 3D brief.

Experimental branch:
- `rooms-3d-foundation`
- `rooms-space-3d-foundation-v1.html`
- commit `7f041b81ff546931aef5e017cb61d4bf948b7618`

This foundation is a procedural Three.js prototype with terrain, house massing, floors, stairs, pool, summer kitchen, sport zone, bungalow, hammock, fountain, hotspots, camera controls, floor navigation, light toggle and selected-object card. It is **not final art** and must not be treated as production-ready geometry.

Next Rooms work:
1. visually inspect the foundation;
2. correct geometry against the established textual plan;
3. improve materials, vegetation, roofs, windows, doors, terrain and lighting;
4. replace approximate geometry with the real architectural plan when available;
5. connect hotspots to real room IDs/catalog/photos;
6. connect availability and existing booking flow without rewriting backend logic.

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
Current verified HEAD before this documentation update: `ec375dea95016b5cb67d59342ffbcba5eb635f5d` (`Add files via upload — Вид главной`).

The persistent summary file is present on `main` at:
`INFORMATION-SUMMARY-FOR-CHAT-TRANSFER.md`

### `feat/live-availability-bridge`
The previously documented V12 branch remains experimental. Verify its exact tip before making further changes.

## Current V11 / V12 homepage work
`freedom-orbit-v11.html` and `freedom-orbit-v12.html` remain experimental homepage/Orbit prototypes. Preserve the five-direction architecture and existing mechanics. Do not restart the homepage because of the Rooms work.

## Vercel
Vercel project: `freed-om`, connected to `freedomsochi/FreedOm`.
Deployment state must be freshly verified before claims about current production/preview.

Do not deploy experimental homepage or Rooms 3D work to production/main until visually and functionally validated, especially on mobile.

## Visual source
`Фридом pdf (1).pdf` contains 53 pages of real FreeDom visual material: wood interiors, brick, greenery, pool, garden, balconies, rooms, attic, fireplace, sauna, people, shared meals, events, meditation, music, tea ceremony and territory.

## Current task / next steps
1. Continue the existing five-direction homepage architecture; do not redesign it around Rooms.
2. Rooms is the current remaining major visual branch; Banya, Space and Events are already structurally established.
3. Build the Rooms 3D foundation into a convincing spatial model.
4. Treat the approved generated image as the visual/UI quality reference, not as a literal plan.
5. Use real architectural/photographic materials later to replace assumptions.
6. Preserve existing booking, CRM and Supabase logic.

## Non-negotiables
- Do not endlessly create versions without a concrete improvement.
- Do not rewrite working CRM/backend for visual convenience.
- Do not merge experimental work into `main` until tested.
- Do not invent content/data when existing project data exists.
- Phone is a primary scenario; do not merely shrink desktop.
- Preserve real tree, real photos, warm glassmorphism, physical Orbit, atmospheric transitions, fullscreen worlds and enter/return metaphor.
- For Rooms, do not use primitive-looking blocks as final art; the target is a professional 3D spatial environment.
- The generated reference does not override the actual FreeDom plan.

## Chat-transfer rule
Update this file approximately every **5 working messages**, especially after meaningful code, architecture or deployment changes. If exact automatic timing is impossible, update at the next practical checkpoint and record the latest state.

## Important correction history
A previous summary incorrectly stated that the final architecture was three directions. The user corrected this: **the final Orbit has five rooms/directions — Пространство, Кухня, Баня, События, Комнаты.** That correction is authoritative.

## Final metaphor
**One living house, not a collection of unrelated pages.**

- Homepage = entrance.
- Orbit = path.
- Each of the five directions = a door into a part of FreeDom life.
- Account = tool.

The interface should not say “Here are our sections.”
It should visually communicate:

**«Вот FreeDom. Куда хочешь пойти?»**
