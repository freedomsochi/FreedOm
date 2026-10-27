## Latest implementation checkpoint — 2026-10-28

- Current target branch: `rooms-architectural-v1`.
- Latest code change: commit `4ea404bf2dde56a64c1f59e3f3a337a295bdd3b8` — `Improve Rooms floor navigation and mobile panel layout`.
- File changed: `rooms-architectural-v1.html`.
- Changes: floor selector moved from a vertical left rail to a compact bottom horizontal row; selector can scroll horizontally on narrow screens; displayed levels are now `Территория`, `1 этаж`, `2 этаж`, `3 этаж`, `4 этаж`, `Мансарда`; detail card sits above the selector on mobile; button transitions respect `prefers-reduced-motion`.
- Preview URL (HTTP 200 verified): https://freed-cqssl7fuq-sergeyogorodnik19-3325s-projects.vercel.app/rooms-architectural-v1.html
- Verification limitation: source response was checked and returned HTTP 200, but no rendered visual/browser interaction inspection was performed. User should visually check mobile layout and floor-to-model mapping.
- Important next step: this change only updates navigation presentation/labels. Verify each displayed floor shows the correct real architectural level. Current model data still contains approximate/inconsistent floor definitions and must be reconciled against `ROOMS_ARCHITECTURAL_PLAN.md` and the user's latest agreed floor inventory before claiming the room geometry is accurate. Do not connect or rewrite booking logic until existing integration is inspected.

# CURRENT WORKING AGREEMENT — 2026-10-28 (READ THIS FIRST)

> This section is the latest user-approved work plan and overrides older/conflicting implementation directions below. The current target build is **`rooms-architectural-v1`**. Continue from the existing build; do not restart or replace successful work with a new prototype.

## Main principle and workflow
- Work specifically on the current `rooms-architectural-v1` build and preserve solutions that already work.
- Sequence: **(1) fix visual glitches and interaction; (2) add real photographs and atmosphere.**
- The site should remain lightweight and calm: real FreeDom photographs and nature are the foundation; animations and interface effects are restrained enhancements, not the main attraction.
- Use a working branch and Vercel preview. Do not change `main`/production before testing and explicit approval.
- Test mobile first, especially initial load, touch interactions, text readability and transitions.
- Preserve existing database, authentication, booking/availability, events registration, kitchen/order and admin logic. Connect new UI to existing flows; do not create replacement systems for convenience.
- Use real repository photographs first. Generate only images that are genuinely missing, with filenames agreed in advance. Limit generation to **up to three images per day**; reuse suitable real images where possible.

## Repository cleanup — safety rule
- Separate visual loading glitches from unused repository files; these are different tasks.
- Fix loading flashes in the homepage code without conflating that work with repository cleanup.
- Before removing files, inspect references, routes, direct links, integrations and imports. The repository contains multiple admin pages and booking tests; names alone do not prove a file is unused.
- First make an inventory of candidates and confirm they are unreferenced. Delete only verified duplicates or obsolete pages from the active work path. Never mass-delete admin, booking, event or test files based only on filenames.
- Previous work notes report a separate cleanup preview from branch `work/2026-10-19-ux-cleanup`; this is historical evidence, not permission to treat that branch as the current target. Current task target remains `rooms-architectural-v1`.

## Page-by-page plan and priorities

### 1. Homepage — Priority 1
- Verify on a phone that the tree, Orbit/circle, logo and account controls appear together only after initial loading; no fragments should flash early.
- Preserve the five Orbit directions and current rotation mechanics: **Пространство, Кухня, Баня, События, Комнаты**. The personal account remains separate.
- Keep the composition of the circle; improve cohesion through correct loading, real photographs and subtle motion rather than redesigning the Orbit.
- Add a soft tree reveal, restrained light and barely noticeable background movement. Avoid heavy, continuous animation.
- When a direction changes, change the atmospheric photograph/scene where supported, not only the gradient color.
- Standalone pages should use a consistent, clear **«На главную»** control.

### 2. Пространство — Priority 1
Implement and verify the interaction before adding effects:
- A normal vertical swipe advances exactly one section, even if the swipe is strong.
- Add a short lockout after each completed transition to prevent accidental double-advances.
- A deliberate long press followed by a sustained/extended drag enables sequential multi-section skipping.
- Horizontal galleries remain horizontal and do not conflict with vertical navigation.
- Mouse-wheel input advances one section per step.
- Keep the existing story/card sequence and working design. Give cards distinct, restrained character effects only where useful: gentle photo parallax, soft light, subtle leaves/steam, smooth text reveal. Do not apply every effect to every card.

### 3. История проекта — Priority 1
- Keep a single **«На главную»** link in the top area; avoid duplicate top navigation/close controls.
- Clicking the tree triggers one short, expressive interaction: slight tree turn, golden light travelling through branches/roots, then a few sparks. No constant fireworks.
- Preserve the already accepted tree photograph and root composition. The selected image filename provided by the user is `images/Золотой свет древнего дерева.png`; on the working branch verify the exact current page and asset path before changing it.
- Replace the flat, monotonous green treatment with photographic fragments, soft shadows, texture and a gradual reveal of the story, while retaining legibility.
- When the owner provides the real history text, compose it around the tree/roots without covering important parts of the image. Do not invent historical facts or participant details.

### 4. Кухня
- Keep the existing concept; do not rebuild the page from scratch.
- Use the photograph as the scene foundation and adapt interface to the real kitchen's light, perspective and details rather than covering it with panels.
- Improve text legibility, transitions and hierarchy; verify narrow mobile layouts.
- Preserve existing kitchen/order behaviour and backend integration.

### 5. События — Priority 2
- Opening an event card should immediately show meaningful content, not an empty area.
- Each event needs a title and photo, date/time, clear description, host/organizer, price and **«Записаться»** action.
- If date or price is unknown, explicitly show **«Уточняется»**, not an empty field.
- Connect registration to the existing mechanism; do not create a second registration system.
- Replace the burgundy-only look with real FreeDom event imagery, warm light and restrained darkening behind text.
- Keep event photos consistent in treatment and use approximately 4:5 card framing where appropriate.

### 6. Баня — Priority 2
- Add **«На главную»**.
- Make the individual-sauna card clearly clickable.
- Its detail view should show photo, description, capacity, duration, conditions, price and order button.
- Verify where the request should go and connect the existing supported order/request mechanism.
- Visual direction: wood, steam, water, stone and natural light. It should feel like part of a real home, not artificial luxury spa branding.

### 7. Комнаты — Priority 3; images/plan are essential
- Continue on the current **`rooms-architectural-v1`** build and preserve its successful decisions.
- Remove any unrelated/random house photo currently used inside the control panel.
- The base should be a top-down plan of the actual FreeDom house/territory, not a guessed layout. The supplied architectural PDF/plan is authoritative for geometry.
- Put interactive circular hotspots over actual rooms/areas.
- After date selection, show rooms available for those dates; after selecting a room, show its large photo, description and booking controls.
- Restore/keep the bottom floor selector: **1, 2, 3, 4, мансарда**. Choosing a level changes the central image and highlights the corresponding region on the plan.
- Preserve current Supabase/database availability and booking logic. Inspect the integration before editing; connect the new UI to it rather than rewriting it.
- Do not generate a fictional floor plan or use generated images as a substitute for architectural truth. Generate room-level atmosphere photos only where real suitable images are missing.

## Shared visual and technical rules
- Overall image style: realistic FreeDom, not an abstract eco-hotel. Natural materials, greenery, water, warm light and lived-in atmosphere; no text/logos embedded in generated imagery and no random futuristic details.
- Leave clear areas in photos for interface overlays; composition must work on mobile.
- On phones, body copy should usually be about 14–16 px; secondary labels at least 11–12 px; headings responsive and hierarchically distinct.
- Animations usually 250–700 ms, only when useful. Respect `prefers-reduced-motion`.
- Use appropriately sized images and lazy-load large/offscreen images; avoid flicker when scenes change.
- Keep text on a calm, readable background and avoid covering important real-photo details with glass panels.
- Do not invent dates, prices, availability, room geometry, participant names or project history. Show “Уточняется” when the value is unknown.

## Image backlog / proposed order (maximum three generated images per day; adapt to available real photos)
1. **Пространство — key scenes:** main house/greenery, practice hall, starry evening pool.
2. **Пространство — supporting cards:** tea conversations, work zone, library or music studio, depending on actual photo gaps.
3. **События:** distinct imagery for singing bowls, meditation, sauna, karaoke and community meetings; reuse real suitable images.
4. **Баня:** exterior, steam-room interior, rest/cooling area.
5. **Комнаты:** verified top-down plan and first levels; then remaining levels/attic only if separate images are genuinely needed.
This is a flexible queue, not a requirement to generate every item. Search the repository/PDF first and avoid duplicate generations.

## Execution order
1. Validate the current homepage loading and safely inventory cleanup candidates.
2. Fix and test Space swipe/scroll behaviour.
3. Refine the history page interaction and photo integration.
4. Fix Events card completeness and existing registration flow.
5. Refine the sauna page and connect its existing order flow.
6. Continue Rooms UI only against the authoritative plan and real data; preserve availability/booking.
7. Finish with a cross-page mobile, typography, loading and performance pass.
Work on independent pages can proceed in parallel when it does not interfere with the priority sequence.

## Handoff requirements for every new chat
- Read this file first and treat this current-work section as authoritative.
- Verify the current branch, latest commit and preview deployment before coding or claiming a change is live.
- State what has actually been changed versus what remains planned. Never claim visual verification without actually inspecting the page.
- After meaningful implementation checkpoints, update this summary with branch, commit, deployment and next task. Do not change production without approval.

---

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
