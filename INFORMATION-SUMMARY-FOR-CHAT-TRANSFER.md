# ROOMS PAGE FEEDBACK — 2026-10-28 (LATEST)

User's latest correction:
- Approved background image is exactly `images/d858f8c1-6079-463e-bafb-a046f2325f0a.png`; do not use `4d284d38-6fda-471a-aacc-050528e57da0.png` as the page's outer background.
- The central area is the top-down house/territory view and should be treated as a real control panel, not decoration.
- Desired behavior: choose a type/category at the top to filter options; selecting a room should take the user down to the full room information.
- User considered a different accurate top-down projection for each floor, but noted daily image generation limit and accuracy difficulty. Offer vector overlays / floor layers as an alternative before generating multiple floor images.

Latest code update on `rooms-architectural-v1`:
- Commit `b80cc37237f7eee23c3d32324b7f53bf35eebae1` — “Restore approved Rooms background and speed up image loading”.
- Outer background now references the approved `d858f8c1-6079-463e-bafb-a046f2325f0a.png`, served through an image resizing/compression proxy (1800px, quality 78, WebP).
- Central scene retains the top-down house/territory image `4d284d38-6fda-471a-aacc-050528e57da0.png`, also requested through resize/compression (1600px, quality 78, WebP).
- Room thumbnails/detail thumbnails have `loading=lazy` and `decoding=async`.
- Branch only; no production/main changes.
- Vercel deployment for this commit was still BUILDING when last checked; recheck before sharing the newest preview.
- Image optimizer endpoint has not yet been independently verified by a browser/image fetch. If it fails, use a branch-local optimized asset rather than reverting to the wrong background.
- No visual browser/touch test has been performed yet.

Recommended panel design (pending user confirmation):
1. Keep one approved overhead territory image in the center.
2. Add a clear floor/layer selector: “Территория”, “1 этаж”, “2 этаж”, “3 этаж”, “4 этаж”, “Мансарда”.
3. Avoid generating a separate bitmap for every floor. Instead draw floor plans as SVG/vector overlays from the authoritative PDF and switch the layer over the same background. Only show room markers where geometry is confirmed by the plan; never invent room positions.
4. Keep the top categories as filters for room type; category selection shows every relevant option. Clicking a room marker/card smoothly scrolls to its details and booking section.
5. If the PDF does not provide enough geometry to make a reliable overlay, use a transparent floor-information panel/list over the photo until geometry is confirmed rather than fake precision.

Continue work on the approved page `rooms-eco-futurism-v2.html`, not the experimental 3D page. Inspect deployment, image optimization, then implement the chosen control-panel behavior. Preserve availability/booking integrations.

---

# LATEST APPROVED ROOMS PAGE CHECKPOINT — 2026-10-28

- Correct page is `rooms-eco-futurism-v2.html`, the Rooms destination opened from the Orbit; not `rooms-architectural-v1.html` (the experimental model).
- Branch: `rooms-architectural-v1`. Production/main unchanged.
- Latest code commit: `966a6f517b61fd3740e450a69b453eaace349008`.
- Preview URL for latest code commit: `https://freed-d937e38cc-sergeyogorodnik19-3325s-projects.vercel.app/rooms-eco-futurism-v2.html` (Vercel response HTTP 200; source contains the latest changes).
- Completed in this pass:
  1. Replaced unrelated Unsplash room thumbnails/details with local FreeDom photos: `images/room-family.jpg`, `images/room-hostel.jpg`, `images/room-balcony.jpg`, `images/room-bungalow.jpg`.
  2. Replaced the two unrelated stock scene backgrounds with the user's house image `images/4d284d38-6fda-471a-aacc-050528e57da0.png` served from the existing main-branch asset.
  3. Removed invented room dimensions, unsupported sea-view/panoramic-window claims, incorrect “6 guests” hostel claim and initial fake “available” statuses.
  4. Removed hardcoded past dates so the existing date initializer supplies valid dates.
  5. Corrected visible names to “Семейная комната”, “Хостел стандарт”, “Двухместный с балконом”; availability and booking code were not rewritten.
- Verification: fetched the latest preview page successfully (HTTP 200); its HTML contains the house image URL and all local room photo paths, has no Unsplash image URLs, and no longer contains the removed invented details.
- Limitations still open: no rendered browser/touch inspection yet; central house image is currently referenced from the main-branch raw GitHub URL rather than copied as a branch-local binary; room catalog remains partly hardcoded and should be reconciled with actual catalog data; the current page's booking button still opens Telegram, while the repo also has `POST /api/booking` forwarding to `create-public-booking`. Inspect request payload/flow and make a deliberate safe integration change in a later stage.
- Next step: inspect current page mobile layout and current catalog/booking behavior, then reconcile real room categories/data without changing the approved visual composition.

---

# ACTIVE CORRECTION — 2026-10-28: WORK ON THE APPROVED ROOMS PAGE, NOT THE 3D MODEL

The user explicitly corrected the direction: recent work on `rooms-architectural-v1.html` is the wrong page because it focuses on a 3D/architectural model. Do not continue that model as the Rooms page and do not treat it as the currently approved UI.

## Correct target
- The existing Orbit on `index.html` opens `rooms-eco-futurism-v2.html` for the Rooms direction. This is the page to improve.
- Work only on the non-production branch `rooms-architectural-v1` unless the user explicitly changes this instruction.
- Keep the approved photo-background + translucent glass/holographic panel interface and its current page composition. Do not replace it with the 3D model or the unrelated `availability_map_v7.html` catalog.
- Do not change `main` or production.
- Preserve existing category navigation and availability integration until each has been inspected; don't invent room dimensions, capacity, prices, or availability.
- Use actual FreeDom photo assets in `images/`, not unrelated Unsplash room photos.
- The page currently uses the Supabase public-availability endpoint and routes the booking action to the FreeDom Telegram contact. Inspect existing booking paths (including `availability_map_v7.html` and current API handlers) before deciding whether to change this; do not silently replace the flow.

## Work order agreed with user
1. Identify and inspect the approved page and references; separate it from 3D model experiments.
2. Audit the approved page's mobile layout, visual glitches, images, categories and interactions.
3. Replace unrelated stock room photos with real FreeDom assets while preserving the interface.
4. Verify room categories and data against the actual catalog; ask the user only where house facts cannot be verified.
5. Inspect and preserve the existing availability/booking integration before changes.
6. Finish mobile/readability/reduced-motion checks, verify preview deployment, document changes and share the preview.
7. Continue in small completed stages whenever the user says “Продолжай работу”.

## Current approved-page checkpoint
- Correct file: `rooms-eco-futurism-v2.html`
- Branch: `rooms-architectural-v1`
- Latest approved-page change: commit `1da671701917bc2f47ba8e9aa580b5e1dcbfe60b` — replaced the three unrelated Unsplash room images with local assets:
  - `images/room-family.jpg`
  - `images/room-hostel.jpg`
  - `images/room-balcony.jpg`
  - Bungalow detail image uses `images/room-bungalow.jpg`
- This was a photo-only change; availability and booking logic were not changed.
- Vercel preview for this commit was still BUILDING at checkpoint time. Verify state and page URL before sharing it as READY.
- The central scene/background still contains external Unsplash images and needs review against the user's actual house/territory image assets before replacing them.
- No rendered browser/touch visual inspection has yet been performed. Do not claim it has.
- The 3D model branch/file can be revisited as a separate task only if the user asks.

---

## Latest implementation checkpoint — 2026-10-28

- Current target branch: `rooms-architectural-v1`.
- Latest Rooms code commit: `5451294a39f4adb9f29728d3ef751a1cf1ac1dd4` — `Align Rooms selector labels with agreed floor numbering`.
- Related code commit: `c2059b101f23a524367e8718ed00e08cbe9fd18d` — fourth-floor double rooms and two attic room zones/hotspots.
- Related UI commit: `4ea404bf2dde56a64c1f59e3f3a337a295bdd3b8` — bottom horizontal floor navigation, narrow-screen horizontal scroll, mobile card clearance, reduced-motion support.
- Current `rooms-architectural-v1.html` changes: bottom selector labels `Территория`, `1 этаж`, `2 этаж`, `3 этаж`, `4 этаж`, `Мансарда`; internal IDs map to the existing level models (`-1`→display 1, `1`→display 2, `2`→display 3, `3`→display 4); fourth floor contains two double-room zones plus yoga/practice and balcony; attic contains two room zones and selectable hotspots.
- The preview for commit `c2059b1` was HTTP 200, but it predates the final selector-label commit. Latest preview is being generated and must be checked before sharing it as current.
- No rendered visual/browser interaction inspection has been performed. User should verify mobile layout and whether each displayed floor matches the agreed inventory.
- Geometry remains a proportional prototype. Reconcile all floor data with `ROOMS_ARCHITECTURAL_PLAN.md`, the plan addendum, and the user's latest agreed room inventory before claiming architectural accuracy. Do not rewrite booking logic; inspect existing integration first.


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

# VISUAL / INTERACTION PASS — 2026-10-28 (after design feedback)

User emphasized that vector illustrations made so far have looked weak/outdated; design priority is a strong modern graphic language, or simple but tasteful. Keep the real photo and polished glass interface; do not add weak decorative vector floor plans or fake room geometry.

Changes on branch `rooms-architectural-v1`:
- Commit `3159e0a016d1b954e24c0db3cbd9fd322d89687b` added a refined floor/zone selector over the real aerial scene and an information surface showing only the agreed inventory:
  - Territory: house/garden/common space
  - 1st floor: sauna, no accommodation rooms
  - 2nd floor: economy hostel and living room
  - 3rd floor: standard hostel, family room, admin room
  - 4th floor: two double rooms and yoga hall
  - Attic: two rooms
- Floor controls update the selected state and the corresponding information text. This is deliberately a clean UI-level floor selector, NOT a claim that the photo contains geometrically accurate floor overlays. Accurate overlays remain a future step only if grounded in the authoritative PDF.
- The existing category selector remains in place. Clicking a room card or a room marker scrolls to the details panel on mobile; reduced-motion preferences are respected. Desktop details remain visible in the right-side panel.
- Commit `dbee876facb3ca8342b06e4f60490cff8e51a064` refined the floor label and removed the unsupported “room with a view” wording.
- Existing availability endpoint, booking CTA and Telegram booking flow were not rewritten.
- The approved outer background is still the exact `d858f8c1-6079-463e-bafb-a046f2325f0a.png`; the central scene still uses `4d284d38-6fda-471a-aacc-050528e57da0.png`.
- Not yet verified: rendered browser/touch appearance, actual image proxy performance, and final Vercel status for the newest commit. Do not claim those tests passed until checked.

- Follow-up correction commit `2bd86a358e18272faacc132fb0778b60eda1dcea`: removed unverified room-position pins and the misleading “360°” indicator from the aerial panel. The photograph is not a verified interactive 360° model, and room positions should not be implied without plan-backed geometry. The real controls are now the room-category tabs and floor/zone selector.
- Preview for the code commit before this last small correction was READY at `https://freed-hx4guxguv-sergeyogorodnik19-3325s-projects.vercel.app/rooms-eco-futurism-v2.html`; the newest commit must finish deployment before its preview is shared as the latest.
