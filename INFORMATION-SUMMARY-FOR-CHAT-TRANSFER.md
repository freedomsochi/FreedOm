# FreeDom Sochi — Information Summary for Chat Transfer

> Living project state for continuing FreeDom work across ChatGPT chats. This file is a continuity aid, not a substitute for verifying the repository. Before making changes: read this file, inspect the actual GitHub state, reconcile differences, then continue.

## 1. Project identity
- Repository: `freedomsochi/FreedOm`
- Supabase project: `vutmbhsclmcfqqlzxqkc`
- Main production line: `main`
- Experimental visual line: `feat/live-availability-bridge`
- Goal: rebuild the FreeDom homepage as a living digital entrance into the real FreeDom house, while preserving the existing CRM/backend/business logic.

## 2. Core concept — NON-NEGOTIABLE
FreeDom is NOT simply a hotel, hostel, SaaS, CRM, game menu, or service catalog.

Core idea: **“FreeDom — дом в котором есть жизнь.”**

The site should make a visitor think: **“Что здесь происходит? Хочу заглянуть внутрь.”**

FreeDom combines accommodation, nature, communication, friendship, creativity, sport, self-development, events, sauna, kitchen, communal life and self-discovery. It should feel like a real living house with an unusual digital interface.

Main emotional effect: “I didn’t open a hotel website. I looked inside a living world. There is somewhere to go.”

## 3. Philosophy
- Friendship and mutual help.
- Family not by blood but by spirit.
- Love, kindness, faith in people.
- Dreams, goals, motivation and energy.
- Freedom from imposed social roles.
- A place for people who are lost, tired, changing direction, or trying a different life.
- You do not have to know immediately what you want. You can try, make a mistake and turn another way.
- “Play life”; remain a child even at 50+.
- The house is like a film where each resident has a storyline.

Do not turn the philosophy into abstract marketing copy. It should be communicated through the real house, people, activities and atmosphere.

## 4. Homepage architecture — CURRENT DECISION
The final agreed architecture is **3 main Orbit directions**:

1. **Пространство** — what is this place?
2. **Комнаты** — where will I live?
3. **Кухня** — what about food/daily life?

**Баня** and **События** are NOT main Orbit doors; they belong inside **Пространство** as elements of FreeDom life.

Personal account is separate from Orbit, subtle in a corner:
- unauthenticated: `Войти`
- authenticated: profile/name
- contains bookings, orders, user data and existing account functions
- must not compete with the main navigation.

Homepage composition:
- FreeDom
- “дом в котором есть жизнь”
- central real tree/branches
- Orbit around it
- 3 directions
- “выбери свой путь” as an invitation to explore, not a CTA
- separate account control

## 5. Visual language
Preserve:
- real FreeDom photography, never random stock/Unsplash;
- `images/branches.png` as the real tree/branch foundation;
- warm glassmorphism;
- natural wood, red brick, greenery, water, graphite, soft metal;
- transparent glass, blur, reflections, soft sunlight;
- airy, organic, cinematic, minimalist but alive;
- subtle idle motion: light, leaves, water/reflections, depth;
- modern technology that still feels like a home.

Avoid:
- cyberpunk;
- cold sci-fi;
- spaceship/space interface;
- black futuristic UI;
- ordinary hotel landing page;
- card catalog;
- SaaS dashboard;
- game menu;
- five identical landing pages;
- abstract AI art replacing real FreeDom;
- beautiful animation without meaning.

## 6. Tree
Real file: `images/branches.png` with alpha channel.

Branches must remain. Do NOT remove the tree to hide visual problems.

Known issue from Orbit experiments: an ugly square/rectangle can appear around the central branch image. First inspect the PNG and its rendering/alpha treatment. Fix display/masking only; do not replace the tree unnecessarily.

## 7. Orbit interaction
Orbit should feel like a path around a living house, not a standard menu.

Desired mechanics:
- touch/drag follows the angle of the finger, not merely horizontal swipe;
- physical rotation;
- inertia after release;
- smooth slowdown;
- snap to nearest item;
- labels stay upright/readable;
- selected item becomes more material/brighter, without aggressive glow;
- the world/atmosphere can react gradually to selection through photos, light, depth, temperature/mood/particles/highlights/scale;
- transitions should feel like opening a door.

On selection:
`Home → World → Home`

Desired world transition:
1. user selects a direction;
2. atmosphere starts changing;
3. Orbit dissolves;
4. tree/background recede;
5. selected world expands to fullscreen;
6. user explores/scrolls inside it;
7. return dissolves/zooms out;
8. tree and Orbit return;
9. previous Orbit position is restored.

Especially liked concept: enter the photograph and let the selected image become the world.

## 8. Existing Space — DO NOT RECREATE
The repository already contains a substantial Space experience. Known files include:
- `space.html`
- `space-v2.html`
- `space-preview.html`
- `space_map_v1.html`
- `freedom_space.html`
- `freedom_space_v8.html`
- `freedom_space_v9.html`

Space has evolved through fullscreen/cinematic scenes, vertical storytelling, real photos, house/territory scenes, events, sauna/pool/star scenes, galleries and mobile adaptation.

Historical navigation includes:
- yoga hall → balcony
- attic room 1
- attic room 2
- standard hostel
- balcony → open star zone
- spatial arrows/labels

The correct strategy is to integrate the existing Space as the first fullscreen World rather than rebuild it.

## 9. Rooms
Rooms are a main direction because the visitor needs a concrete answer to “where will I live?”

Known categories from prior project context:
- family room
- double room with balcony
- attic room
- bungalow
- sleeping place on balcony
- standard hostel
- economy hostel

Do not invent categories. Verify actual database/catalog data before implementation.

Preserve the real physical house → rooms → real data relationship.

## 10. Kitchen
Kitchen is a main direction, but must feel communal/home-like, not like a restaurant.

Existing kitchen/backend/order logic must remain intact. Inside Kitchen may expose menu, products, orders, shared kitchen and atmosphere.

## 11. Sauna and Events
Not main Orbit doors.

Inside Space they can appear as parts of FreeDom life:
- sauna/steam/warm light/water/hot-cold contrast;
- music, lectures, meditation, sport, cinema, karaoke, evening meetings, bonfire, shared work, birthdays and holidays.

## 12. Real visual material
An important attached source is `Фридом pdf (1).pdf`, 53 pages, primarily visual.

Material includes:
- wooden interiors;
- red brick;
- greenery;
- pool;
- garden;
- balconies;
- rooms and attic;
- fireplace;
- sauna;
- people;
- shared meals;
- events;
- meditation;
- music;
- tea ceremony;
- evening atmosphere;
- views from balconies;
- territory.

The visual material is intentionally sometimes ordinary/busy rather than luxury-perfect. That is valuable: FreeDom should feel alive, not like a rendered hotel.

## 13. Existing business/CRM system — PROTECT
Repository contains a full business/CRM/backend system, including auth, users, guests, rooms, bookings, availability, orders, kitchen, admin, notifications, RLS, RPC and business logic.

Known important work:
- dashboard UX sprint: `928608138abf5e5ee0f93d813357f5c1e24cd8df`
- kitchen workflow/RPC: `282c885f748fed7736a10ded8651624483ccfc6d`
- public booking atomic RPC line on `main`: `c84c8604...`

Do not break:
- auth;
- RLS;
- booking logic;
- CRM/dashboard;
- kitchen/orders;
- RPC/data model;
- notifications;
- existing Space functionality.

Old booking notifications used Formspree → Telegram. Kitchen notifications were being integrated into the same Telegram app. Payment integration status must be verified before changing anything.

## 14. Git branches / two project lines
There are two important lines:

### `main`
Known verified state from the audit:
- HEAD: `c84c8604eb1659b6e91fd021aa44c6ed421b28c6`
- commit: `Use atomic public booking RPC for room reservations`
- date: 2026-08-27
- contains working CRM/backend/business system and older homepage.
- `index.html` was still the older site with “FreeDom — космический центр развития”, dark/stars/cards/events/sauna etc.
- It also contains the existing Space files and real images.

### `feat/live-availability-bridge`
This is the experimental visual line containing Orbit V1–V10 and subsequent homepage experiments.

Important: verify the actual branch tip before making claims or new changes. Do not rely on an old remembered SHA.

## 15. Orbit history — preserve good decisions, do not blindly take latest
### V5
Commit `933b8c0186a15608ae476f0cbd93037f48ba1fb9`
Message: `fix: use real FreeDom tree, real house photos and direct Space navigation`

Established:
- real branches/tree;
- real house photos;
- direct Space navigation;
- angle-based rotation;
- inertia/snap;
- readable upright labels;
- glassmorphism;
- sunlight/atmosphere.

### V6
Commit `24650bc7a46f6f4e2c7bd6b027608963142c63e5`
Message: `feat: evolve orbit into immersive biophilic glass interface`

Added/refined:
- photographic background;
- tree;
- glass Orbit;
- soft light;
- transparency/blur/reflections;
- physical rotation;
- active item;
- living central element;
- atmosphere reaction.

### V7–V10
Further experiments. Latest is not automatically best. V9/V10 explored fullscreen World and Space iframe transition.

Known V9 state on the experimental branch:
- five nodes: `Пространство`, `События`, `Комнаты`, `Баня`, `Кухня`;
- real `images/branches.png`;
- real photos;
- angle rotation, inertia, snap, upright labels;
- fullscreen-ish World layer;
- `openSpace()` loading `space-preview.html`.

V10 is essentially a wrapper around V9 for the Space presentation experiment.

## 16. V11 status — IMPORTANT LATEST PROJECT CONTEXT
A first V11 prototype was implemented on `feat/live-availability-bridge`.

Reported commit:
`21b874ec` — `feat: build five-branch FreeDom Orbit homepage`

Reported V11 changes:
- five directions instead of three;
- preserved physical Orbit rotation, inertia and snap;
- real FreeDom photos;
- real `branches.png`;
- separate “Личный кабинет” element;
- atmospheric background reaction to selected branch;
- Space opens through existing `space-preview.html`;
- soft mask around the branch image to reduce the visible rectangular area without removing branches;
- `main` was not changed.

Reported preview:
`https://freed-3ao8u8wwx-sergeyogorodnik19-3325s-projects.vercel.app/freedom-orbit-v11.html`

The V11 report explicitly said this is an architectural first sprint and only Space is fully connected; the other branches were visual placeholders pending connection to existing project logic.

**Conflict to preserve:** the current V11 prototype has 5 visible branches, but the later agreed final homepage architecture is 3 main doors (Space / Rooms / Kitchen), with Sauna and Events inside Space. Do not treat V11’s five-branch implementation as the final architecture. Use it as an interaction/visual prototype and migrate its best mechanics into the 3-door model.

Also verify the actual current branch and commit because the V11 report is historical project context, not a live GitHub query.

## 17. Vercel state from the audit
Vercel project: `freed-om`, connected to GitHub `freedomsochi/FreedOm`.

The audit found that the latest visual deployment line was associated with `feat/live-availability-bridge`, while production/main remained on the `main` line.

A reported V10 deployment was associated with commit `41bd795`, message `feat: Orbit V10 Space presentation wrapper`.

Do not deploy experimental homepage changes to production/main until the Home → World → Home cycle is visually and functionally validated, especially on mobile.

## 18. Required workflow for future chats
Every new chat should:
1. Read this file.
2. Inspect actual GitHub state: current branch, latest commits, relevant files.
3. Reconcile this file against reality.
4. If this file is stale, update it before major work.
5. Do not restart the concept.
6. Do not invent replacement systems when existing project functionality can be reused.
7. Make surgical changes and preserve working business logic.

Before implementation, distinguish clearly between:
- verified current repo state;
- historical experiment;
- agreed product decision;
- proposed next step.

## 19. Current priority
Do NOT immediately replace `main/index.html`.

First perfect the experimental cycle:

`Homepage → Orbit → selection → transition → fullscreen Space → explore → return → Homepage`

First World = existing Space.

After that, connect Rooms and Kitchen to existing data/logic, and keep Events/Sauna inside Space.

Only after visual/function/mobile validation should the result be considered for production/main.

## 20. Current next step
The next technical action should begin with a fresh factual check of:
- exact tip of `feat/live-availability-bridge`;
- V11 file and surrounding Orbit versions;
- current `index.html` on main and experimental branch;
- current `space-preview.html` / `space.html`;
- actual `branches.png` dimensions/alpha/rendering;
- room/catalog files/data;
- current Vercel deployment state.

Then report a short audit before code changes if the task is a new implementation sprint.

## 21. Recent action history / continuity
- User explicitly asked not to start over and to preserve the exact reasoning behind the FreeDom concept.
- Primary audit was completed with no repository changes at that stage.
- Audit confirmed two lines: production/business `main` and experimental Orbit `feat/live-availability-bridge`.
- User then approved continuing the experimental Orbit line and a V11 five-branch prototype was reported as implemented.
- This file was created to serve as the persistent transfer/context document so future chats do not require manually pasting the entire project history.

## 22. What NOT to do
- Do not blindly merge experimental branches.
- Do not overwrite `main` just because an Orbit prototype looks better.
- Do not rebuild Space from scratch.
- Do not invent room categories or backend logic.
- Do not replace the real tree with an abstract illustration.
- Do not use stock photos instead of real FreeDom material.
- Do not turn the homepage into a hotel catalog.
- Do not make five identical service pages.
- Do not treat V11’s five visible branches as the final architecture; the later decision is three main doors.
- Do not remove branches to hide the central rectangle; fix alpha/rendering/masking.
- Do not optimize for desktop at the expense of mobile.
- Do not create new versions endlessly without a concrete improvement.

## 23. Final metaphor
**One living house, not sections.**

- Homepage = entrance.
- Orbit = path.
- Space = door into FreeDom life.
- Rooms = living.
- Kitchen = daily life.
- Sauna/events = elements of Space/life.
- Account = tool.

The interface should not say “Here are our sections.”
It should say, visually and emotionally:

**“Вот FreeDom. Куда хочешь пойти?”**
