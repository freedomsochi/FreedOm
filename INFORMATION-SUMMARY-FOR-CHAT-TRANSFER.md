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

# STATIC PHOTO / RESPONSIVE CROP PASS — 2026-10-28

User feedback: the page still felt like a photo with buttons; outer background looked blurry, and the photo moved during vertical scrolling. They asked for a static image and deliberate framing for phone and desktop, especially portrait orientation.

Changes:
- Commit `fa965a0f8fd28c099729083b4ff9c1e5fe44ce1c`: replaced remote `images.weserv.nl` compressed/proxied image backgrounds with the original repository PNG assets to avoid unnecessary compression softness; added separate responsive crop positions for desktop, mobile, narrow mobile, and portrait desktop.
- Commit `575360f367f413dcdf9e4d539443ec01245dd021`: corrected the fixed backdrop stacking so it remains visible behind the interface.
- Mobile CSS sets the central territory photo scene to fixed viewport positioning while the content can scroll, and adjusts image sizing/position for portrait screens.
- Need real-device visual validation: fixed-position layers and crop choices have not been checked in a rendered mobile browser. If the photo layer overlays content incorrectly on device, adjust stacking based on a screenshot. Do not claim it was visually confirmed.
- Changes remain on `rooms-architectural-v1`; production/main not touched.


## MOBILE CENTRAL PHOTO EDGE-FILL FIX — 2026-10-28

User reported that the central territory photo was cropped/letterboxed with transparent-looking empty strips on the left and right after the mobile `contain` adjustment. Updated only the mobile central scene sizing in `rooms-eco-futurism-v2.html`: both narrow-screen rules now use `background-size:100% 100%` instead of `contain`, so the full photo fills the central frame edge-to-edge and no side gaps are left. This can slightly stretch the image to fit the frame; it intentionally prioritizes a continuous photo over transparent side bars. Desktop rules and booking/availability logic are unchanged. Commit: `6c83b494296bdd9a649b29727dff86982616597f`. Verify the new Vercel preview is READY before sharing; no rendered-device visual inspection has been performed.


## MOBILE PHOTO FRAME CONTAINMENT FIX — 2026-10-28

Follow-up to the edge-fill fix: user reported the central photo looked square/distorted and extended beyond the glass panel. Root cause: the mobile `.model` rule forced `overflow:visible`, and `background-size:100% 100%` distorted the photo. Corrected mobile styling to `overflow:hidden!important` on `.model` and restored `background-size:cover!important` for the central scene. This clips the image to the panel's rounded bounds and preserves the source photo's proportions; as a consequence, some edge crop is expected, but no empty side strips or overflow outside the frame. Commit: `2bb6990a81dbe87c2d10b88b6e31f345c796b722`. Verify the Vercel preview state before sharing; no actual-device screenshot test has been performed.


## ROOMS IMAGE LOAD PERFORMANCE PASS — 2026-10-28

User reported that photos still load slowly. Checked image payloads through GitHub API: the two main territory/background PNGs are large (central territory image ~3.81 MB; another PNG ~2.72 MB), while the four room-card JPGs on this branch are ~0.30–0.51 MB each. The Rooms page already uses images.weserv.nl to deliver WebP versions of the two main backgrounds; therefore it is not accurate to attribute all delay to Vercel alone. Reduced requested background variants from 1800/1600 px at q78 to 1200 px at q72 and added preconnect/dns-prefetch for images.weserv.nl. Room JPGs remain unchanged to avoid altering image assets without verifying their visual quality. Commit: `69193a3269cf12f91d2838045bded6aaee1c0928`. This should reduce transfer size, especially on phones, but real-world speed still needs checking on the preview; the third-party image optimizer's first response/cache behavior can contribute to delay. No production/main changes.


## 2026-10-28 — Rooms image loading follow-up
- User reported that photos still appear with a delay when opening the Rooms page, even after reducing background image sizes and adding connection warm-up.
- Updated `rooms-eco-futurism-v2.html` to preload the central territory scene at high priority, preload the outer background, and preload the first visible hostel/family room images. This starts image requests during HTML parsing instead of waiting for later CSS/layout discovery.
- Commit: `4cbe26e45f7ccb15d74382c435c679828a404854` (`Preload Rooms photos before page layout`).
- This is a loading-order improvement, not a guarantee that the third-party image proxy responds quickly. Next step if delay persists: remove the proxy dependency by hosting optimized image files with the project.


---

## Image performance checkpoint — 2026-10-28

- Branch: `rooms-architectural-v1`; production/main unchanged.
- Rooms page commit: `aa3e8ba5657faea3993359cc33e2bd3c43cb1488` — `Reduce Rooms background image payloads`.
- Kept the approved two photos and existing image proxy, but reduced transfer size targets: central territory image now requests WebP at 1000px / quality 66 (previously 1200px / quality 72); outer background requests WebP at 1300px / quality 66 (previously 1200px / quality 72). The preload URLs match the CSS URLs, so browsers do not need to fetch a separate variant for the same image.
- Existing early preloads remain for the two scene images and first room thumbnails; connection warm-up for the image host remains enabled. The browser cache explains why repeat visits were much faster after the first successful load.
- This is a transfer-size optimization, not a measured byte benchmark: the image proxy's exact output sizes and browser performance have not been independently measured here. Because URLs changed, the next first visit downloads the new compressed variants once; repeat visits should benefit from cache again.
- Next high-impact option if needed: add branch-local, precompressed WebP assets and remove the third-party image-proxy dependency. This requires creating binary assets and verifying image quality before switching. Do not change main/production.


## Mobile scroll stability fix — 2026-10-28

- Approved page: `rooms-eco-futurism-v2.html`, branch `rooms-architectural-v1`; production/main untouched.
- Commit `cbd00e26150f933327ef086e6110b5754b850f33` — `Keep Rooms search panel stable during mobile scroll`.
- Mobile header (including the date/search panel) now uses a sticky top position and a translucent glass backing, so it remains in place rather than leaving a blank header gap while scrolling.
- Fixed scenery background now uses stable small-viewport height (`100svh`) instead of sizing to the changing dynamic viewport, intended to reduce the background shifting when mobile browser chrome expands/collapses.
- Not yet visually/touch-tested in a real mobile browser; verify the latest Vercel preview. If sticky header feels too tall/obstructive, adjust spacing while preserving the stable position.


## Mobile Rooms viewport edge cleanup — 2026-10-28

- Branch: `rooms-architectural-v1`; production/main remains untouched.
- Page commit `293411b5548d1ef11fe7724c201c468c69960f01` — `Remove mobile Rooms header seam and background gap`.
- Removed the thin translucent bottom border and shadow from the sticky mobile search/header panel so it blends into the glass surface.
- Reworked the fixed mobile scenery layer to fill the viewport with `inset:0` and `background-size:cover`, instead of a hard `100svh` height/size boundary that could expose a blank strip at the viewport edge as browser chrome changes.
- This is a CSS correction; the live phone rendering has not been independently device-tested yet. Verify the latest branch preview. Main/production was not modified.


## Follow-up: remove sticky-header repaint gap — 2026-10-28

- User reported the previous CSS change had no visible effect: a blank/white area remained when scrolling and the search panel appeared to jump back on finger release.
- Page commit `93c056bd88bb9d9595fa0c7f66eef20bdeffda86` — `Remove sticky header repaint gap on mobile`.
- Changed the mobile header from `position: sticky` back to normal document flow so it naturally scrolls away without a sticky placeholder/repaint interaction. Removed backdrop blur from the header, which can trigger compositing glitches on mobile browsers. Kept the scenery fixed to the viewport and retained its full-screen cover framing.
- Previous attempt did not solve the user's observed issue; this is a different implementation, not a claim of verified device success. Test on mobile preview before further adjustments. Main/production remains unchanged.


## Mobile background overscan and header seam — 2026-10-28

- User clarified the remaining issues: a visible translucent line at the top and a white blank area below the background as the search panel scrolls away.
- Page commit `97762743ea8f5f2e8c9e0e60163e75418dd6564b` — `Overscan mobile scenery and remove header seam`.
- Removed the mobile header's translucent gradient entirely, plus border/outline/shadow, to avoid the visible line.
- Enlarged the fixed mobile scenery layer beyond the viewport: top offset `-20svh`, height `140svh`, image size `120svh`; on narrow phones it uses a slightly larger overscan. This deliberately crops/zooms the territory image so scrolling/browser viewport changes are less likely to expose its edge.
- Must be verified on the user's phone; no direct device rendering available. Branch only; production/main untouched.


## Catalog audit — 2026-10-28 (continuation)

- Read the latest Rooms page and queried the existing Supabase `public.rooms` catalog read-only; no database changes were made.
- Confirmed the live catalog has 9 accommodation records: family room, two separate standard-hostel rooms, economy hostel, two balcony rooms, two attic rooms, bungalow, and “Место под звёздами” (the records include the listed room variants; do not treat these as invented content).
- The approved Rooms UI currently shows a family room, one combined standard-hostel card, one combined balcony-room card, and bungalow. Some catalog options (economy hostel, attic rooms, second-level individual options, and “Место под звёздами”) are not yet represented as distinct choices. This is a real remaining gap; next pass should reconcile the UI options with catalog IDs without changing the availability endpoint or booking handoff.
- Verified Supabase catalog details relevant to current cards: standard hostel has two separate 4-place room records, both using `booking_mode=places`; availability code sums their free places. The card previously said only “4 места”, which understated the two-room inventory.
- Page commit `26e9161a4bb029c1474deb567c183821ddb90d9f` — `Clarify standard hostel inventory count`: visible card and detail metadata now say “2 номера · по 4 места”. Availability and Telegram booking flow unchanged.
- Latest preview must be rechecked before sharing; no real-device rendering test has been performed. Production/main remain untouched.


## Rooms catalog expansion — 2026-10-28

- Added distinct selectable cards to `rooms-eco-futurism-v2.html` for every catalog item previously missing from the approved UI: economy hostel, attic room №1, attic room №2, “Место под звёздами”, and bungalow. Existing family room, standard hostel, and two balcony rooms remain.
- The category tabs now select the first matching item and each card carries an explicit category, avoiding the former hard-coded assumption that index 1 is the only hostel. Bungalow is now a real selectable card rather than a placeholder-only category.
- Connected each new card to its exact existing Supabase room name for live availability: `Хостел эконом`, `Мансардная комната №1`, `Мансардная комната №2`, `Место под звёздами`, `Бунгало в саду`. No database changes; availability endpoint and Telegram booking handoff remain unchanged.
- Fixed the card availability label selector so live statuses update the visible `.availability-status` element (previous selector expected a non-existent `.available` class).
- New page commit: `edef61650fee11c7a8168b043e128903f8c4f940` — `Add missing room and hostel catalog options`.
- This is code-level implementation only; verify image URLs, responsive card scrolling, date-based availability and booking handoff in the preview before considering the task complete. Production/main remain untouched.


---

# ROOMS PAGE — FLOOR FILTERS CONNECTED (2026-10-28)

- Target remains `rooms-eco-futurism-v2.html` on branch `rooms-architectural-v1`; production/main untouched.
- New page commits:
  - `d6d98786c079542b91cbfced54f044fe34303e67` — connect floor selector with room/category filters.
  - `ff0048a70db194555998827030e30c0100a43ccf` — clarify the first-floor no-accommodation message.
- Floor selector now filters room cards together with the selected category:
  - Territory: seasonal “Место под звёздами” + bungalow.
  - 1st floor: no accommodation cards; explains that the sauna belongs to this level.
  - 2nd floor: economy hostel.
  - 3rd floor: standard hostel + family room.
  - 4th floor: two-person balcony rooms.
  - Attic: two attic rooms.
- Selecting a floor preserves the current category; if that combination has no rooms, the page displays a clear empty state instead of showing rooms from another floor. Changing category on a selected floor filters within that floor.
- Removed a redundant availability-label update that called `.forEach` on the result of `querySelector` (a single element), which could throw a runtime error. The normal room-card loop already updates each availability label.
- Existing availability endpoint, dates, and Telegram booking handoff were not changed. No database changes.
- Mapping follows the latest user-confirmed inventory for the Rooms page (2nd floor economy hostel; 3rd floor standard hostel/family; 4th floor two-person rooms; attic two rooms). The living room, yoga room, admin room, and sauna are descriptive spaces, not bookable cards.
- Caveat: “Место под звёздами” is assigned to the general territory layer because its exact physical level/position has not been verified; its image currently uses `balcony_bed.jpg` and still needs asset/meaning verification.
- Verification limitation: no real browser/device interaction test has been run. Check the current Vercel deployment and inspect mobile behavior before calling this fully tested.


---

# ROOMS PAGE — FILTER INTERACTION FIX (2026-10-28)

- Target: `rooms-eco-futurism-v2.html`, branch `rooms-architectural-v1`. Production/main untouched.
- Page commits:
  - `757cf684c192df7cf5d51ba920a49817554a340a` — fix room and floor filtering interactions.
  - `ddf8c00ba383e8c9721a0e5641b546c0f95376a2` — keep detail panel hidden until a card is selected.
- Removed “Место под звёздами” from the visible accommodation cards and the JavaScript catalog. It is not to be presented as an official room until confirmed.
- Initial state: room cards and room detail panel are hidden. The user first chooses a category or floor.
- Category selection filters to that category across floors when no floor has been explicitly selected. Floor selection filters to the selected floor; if a category is also selected, both filters apply together.
- On a floor click before choosing a category, all accommodation cards mapped to that floor are shown; the detail panel stays hidden until the user taps a specific card.
- Selecting a room card opens its details. Changing floor/category hides irrelevant cards and displays a clear empty state when no matching accommodation exists.
- Fixed a literal escaped newline between category and floor event listeners that would prevent the script from parsing in the browser.
- Fixed bungalow index after removing the unofficial “stars” listing. Availability endpoint, date validation and Telegram booking handoff remain unchanged. No database changes.
- User reported earlier that floor/category clicks had no effect. Code inspection found the escaped newline causing a JavaScript syntax error, so the click handlers were not running. The source now has a real newline. Browser/device testing is still required to verify end-to-end behavior.


## 2026-10-28 — Rooms: restore initial list and repair filters
- User requested returning to the previous, better-looking behavior while fixing floor/category controls that did nothing.
- In `rooms-eco-futurism-v2.html`, restored room-list visibility on first load; detail panel remains closed until a room card is selected. No official “Место под звёздами” listing was reintroduced.
- Fixed JavaScript collection queries: calls that iterated over multiple room cards, category buttons, and floor buttons now use `querySelectorAll` via `$$`, instead of calling `forEach` on a single `querySelector` result. This initialization exception was preventing all click handlers from registering.
- Confirmed the inline JavaScript parses successfully with `new Function`; no live browser/mobile interaction test has been run yet.
- Commits on `rooms-architectural-v1`: `b42ba4438e4a4f4e0403e6fa7651a34b3a2dfa5e` (restore initial list behavior) and `2b56c4f5ebc0793d26e417cffbc0cf1a6825d5e4` (repair multi-element selectors).
- Production/main remains untouched.


## 2026-10-28 — Rooms: approximate interactive points by floor
- User confirmed that hostel standard №1, hostel standard №2, and the family room belong on the 3rd floor. Following the latest room list, both two-person rooms are also currently assigned to the 3rd floor; yoga hall and shared balcony are on the 4th; attic has two rooms.
- Updated floor descriptions: territory = pool, bungalow, workout area; 1st = sauna and summer kitchen; 2nd = living room, kitchen, economy hostel, summer veranda; 3rd = standard hostel №1/№2, family room, two double rooms; 4th = yoga hall and shared balcony; attic = two rooms.
- Added 18 approximate interactive map points. Room pins open the associated accommodation card; common-area pins update the floor info text. Coordinates are initial visual estimates on the existing aerial background and should be adjusted against the PDF/real photo.
- Changed the double-room display title to “Двухместная комната” (no bathroom/balcony detail in the name; those details stay in the description).
- JavaScript syntax verified successfully with new Function. Live mobile/browser visual interaction testing is not yet confirmed.
- Commits: 918fe668aeba9be980be9fe711a83368f036cc49 (floor descriptions/assignment), 553d9be8d3ff4f9e2749d14f31f37b7d8f0f23bd (interactive map points).
- Production/main remains untouched.


## Rooms update — 2026-10-28 (cross-floor category browsing and map pin fix)
- Updated `rooms-eco-futurism-v2.html` on `rooms-architectural-v1` in commit `930420ed1265300fe86f2025681c06ca98d14ccb`.
- Fixed map pin cleanup: `renderMapPoints()` now removes existing pins with `querySelectorAll` via `$$`, instead of calling `forEach` on a single `querySelector` result. Also corrected other collection selectors used with `forEach` in the page.
- Category selection is intended to show matching accommodation choices across floors; manually choosing a floor filters the list to that floor. Choosing a room opens its details and switches the map to the room's floor. The initial territory view shows the territory while keeping the full catalog visible.
- JavaScript syntax was checked successfully before commit. GitHub was re-fetched at both branch and commit refs; both return content SHA `655ccbfc7dc3f63dc3169945c241c4f0d32d87fd`, confirming the write.
- A Vercel preview deployment for this commit was observed in `BUILDING` state at the time of check; re-check status before calling it ready. Preview only; production/main remains untouched.
