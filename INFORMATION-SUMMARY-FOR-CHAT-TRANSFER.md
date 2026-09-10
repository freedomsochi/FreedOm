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
- Пространство — the FreeDom house, territory, people, atmosphere, nature and wider life of the place.
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

**Current verified state on `feat/live-availability-bridge`: `space-preview.html` now contains the real fuller Space implementation from `main`, copied locally into the working branch.** Its current content SHA is `00c5d5b7374fa8d44fe26bc715aa04753caf53a3`, and the restoring commit is `0043e431a2861b89f5861bd06d5b14321f4f87bc` (`feat: restore real existing Space implementation locally`). The old external Vercel redirect is no longer present in the working branch.

The restored Space is the existing implementation: fullscreen scenes, real FreeDom narrative/content, mobile adaptation, horizontal galleries, and keyboard/touch/wheel section navigation. It still contains its original standalone `← Главная` link to `index.html`; when embedded inside V12's iframe, the parent World close control should currently be treated as the reliable return path. A future surgical improvement can make the Space back control explicitly communicate with the parent Orbit instead of navigating inside the iframe.

## Rooms
Use existing real room categories/data and preserve booking/availability logic. Known project categories include family room, double room with balcony, attic room, bungalow, sleeping place on balcony, standard hostel and economy hostel. Verify actual data before changing.

## Kitchen
Separate Orbit direction. It should feel communal/home-like, not like a restaurant. Preserve existing kitchen/order/backend logic.

## Sauna / Events
Both are confirmed as separate Orbit directions, not hidden under Space.
- Sauna: wood, steam, water, hot/cold contrast, rest, conversation and silence.
- Events: music, lectures, meditation, sport, cinema, karaoke, meetings, bonfire, shared work, birthdays and creative life.

## Backend safety
Repository: `freedomsochi/FreedOm`
Supabase: `vutmbhsclmcfqqlzxqkc`

Do not break Auth, users/guests, rooms, bookings/availability, kitchen/orders, admin/dashboard, notifications, RLS, RPC/business logic or existing Space.

## GitHub state — VERIFIED CURRENT WORKING BRANCH
Working branch: `feat/live-availability-bridge`
Current latest code tip: `0043e431a2861b89f5861bd06d5b14321f4f87bc` — `feat: restore real existing Space implementation locally`.

Earlier relevant commits:
- `103e50a0e7dfb71ee4a71aac9d0754c196a4ee0a` — `feat: refine FreeDom Orbit V12 five-room homepage`
- `42a150cdb1acf9a1cae04b288a9bd39aab14dea2` — `fix: connect Orbit Space to real existing FreeDom Space`
- `5298a637` — `feat: harden Orbit interaction mechanics`
- `ebfeead419a1a3bdcab37246a851be0254a5d486` — `feat: add cinematic Orbit world entry and return`
- `28ab56d63a35a60d2e84f721bc921706be7dfe71` — temporary local Space entry; superseded by the real Space restoration above
- `6fcdff5f1518ff7e03b27fbb9394ec3838999255` — `docs: sync project transfer summary with current Orbit V12 state`

`main` and `feat/live-availability-bridge` are intentionally divergent. Do not merge experimental homepage work into `main` until visually/functionally validated.

## Current V12 — NEWEST IMPLEMENTATION
File: `freedom-orbit-v12.html`

V12 currently:
- keeps exactly five Orbit directions in final order: Пространство / Кухня / Баня / События / Комнаты;
- uses real `branches.png` and real FreeDom photos;
- uses angle-based pointer/finger rotation, inertia, snap and upright labels;
- changes atmospheric background according to selected direction;
- keeps personal account outside Orbit;
- uses a fullscreen World layer;
- starts world entry from the selected real photo;
- zooms the entry photo while Orbit fades/softens;
- for Пространство, loads the now-local `space-preview.html` behind the entry layer and reveals it after load;
- for the other four directions, currently shows only the cinematic entry state and does not pretend those worlds are finished;
- closing restores the entry/photo transition, hides the world and restores the Orbit state/selected position.

The code intentionally uses `about:blank` for unfinished worlds rather than faking completed content. This is prototype behavior and must be replaced by real worlds one by one.

## V12 interaction details
- Drag is based on the angle of the pointer around the Orbit center, not horizontal swipe distance.
- Inertia is applied after release and then the nearest direction snaps into place.
- Clicks shortly after dragging are ignored to prevent accidental opening.
- Arrow keys can select directions; Escape closes the current world.
- Mobile layout has a dedicated media query; phone is a primary scenario, not just a shrunk desktop.
- The selected direction remains the logical `idx`; `rot` is preserved so returning to Home can restore the prior Orbit position.

## Current V12 visual/functional concerns to evaluate next
1. The exact timing between photo zoom, Orbit fade and Space reveal.
2. Whether the transition feels like entering a photograph rather than opening a modal.
3. Whether Space appears without a visible loading jump.
4. Whether closing Space feels like the reverse of entering and returns naturally to the same Orbit position.
5. Make the Space internal `← Главная` control communicate with the parent Orbit when embedded, instead of navigating `index.html` inside the iframe.
6. Mobile touch zones and accidental drag/click behavior.
7. Tree/Orbit composition and whether the branches asset still feels physically integrated into the scene.
8. Avoid the old central rectangle/square artifact; solve it through correct alpha/rendering rather than removing the real branches asset.

## Space integration status
Current feature-branch `space-preview.html` content SHA: `00c5d5b7374fa8d44fe26bc715aa04753caf53a3`.
It is now the fuller existing Space implementation from `main`, locally restored in the working branch. No old Vercel redirect remains in this file.

## Vercel
A previously known preview URL for V11 was:
`https://freed-3ao8u8wwx-sergeyogorodnik19-3325s-projects.vercel.app/freedom-orbit-v11.html`

Vercel project is believed to be `freed-om`, connected to `freedomsochi/FreedOm`, but the connected Vercel API recently returned `403 Not Authorized` when listing projects. Do not invent or claim a current V12 Preview URL until verified.

## Current task / next steps
Continue from V12; do not restart.
1. Validate Home → Orbit → Space → Home as one coherent cycle.
2. Make the Space internal back control parent-aware and finish the reverse transition.
3. Refine transition timing and mobile behavior based on actual browser verification.
4. Only after Space is solid, connect Kitchen, Sauna, Events and Rooms one by one to existing project data/logic.
5. Do not replace `main/index.html` or deploy production until the new homepage has been visually and functionally validated.

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