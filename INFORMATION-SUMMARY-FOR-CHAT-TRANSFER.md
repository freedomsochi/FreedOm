# FreeDom Sochi — Information Summary for Chat Transfer

> Living project state. Read first in a new chat, then verify GitHub before making changes.

## Core concept
FreeDom is a living house/space, not a conventional hotel/hostel website. It combines accommodation, nature, communication, friendship, creativity, sport, self-development, events, sauna, kitchen, communal life and freedom from imposed social roles.

Core phrase: **«FreeDom — дом в котором есть жизнь.»**

Homepage should feel like looking inside a living world, not a catalog, SaaS dashboard, game menu, cyberpunk interface, spaceship or sterile luxury hotel.

## Final Homepage / Orbit architecture
Five directions, in this exact order:
1. Пространство
2. Кухня
3. Баня
4. События
5. Комнаты

Personal account is separate and subtle in the corner; it is NOT part of Orbit.

## Meaning of the five directions
- Пространство — house, territory, people, nature, atmosphere and wider life.
- Кухня — food and everyday communal life.
- Баня — warmth, steam, water, rest and conversation.
- События — music, lectures, meditation, sport, cinema, karaoke, meetings, bonfire, birthdays and creative life.
- Комнаты — real accommodation categories and booking/availability.

## Visual direction — current user-approved basis
Warm, organic, airy glassmorphism: natural light, wood, greenery, water, transparent glass, blur and depth. Modern technology is acceptable only if it still feels like a living home.

Current user corrections:
1. Orbit/circle must be visually centered on the screen.
2. The old visible `images/branches.png` photo is temporarily removed from the homepage because it dominates the composition. A different transparent tree/branch image will be supplied later.
3. The top standalone FreeDom logo/caption is removed because FreeDom already appears in the center of the Orbit.
4. The circular Orbit itself is liked. The photographic images previously used inside the five circular Orbit nodes were NOT liked and should not return in that form. The nodes are now quiet translucent glass/material doors; real photos remain available inside worlds/background atmospheres.

## Orbit interaction
Preserve:
- pointer/finger angle-based rotation;
- drag + inertia;
- smooth slowdown;
- nearest-item snap;
- upright/readable labels;
- selected item becomes more material/brighter without aggressive glow;
- selection feels like entering a door, not a giant CTA.

## Themed living atmospheres — REQUIRED direction
The homepage should react to the selected Orbit direction with a distinct subtle living atmosphere, not merely change a background photo. This was explicitly discussed earlier and is now being implemented in V14:

- **Пространство:** green/sunny feeling, soft rays of sunlight and slowly falling leaves.
- **Кухня:** warm domestic air, floating dust/light particles, gentle everyday warmth; should feel communal/home-like, not restaurant-like.
- **Баня:** steam, moisture and water/ripple movement; warm/cool contrast.
- **События:** mysterious/fairytale/starry atmosphere, glowing stars and a slightly magical night feeling.
- **Комнаты:** calm intimate home atmosphere; minimal movement and soft depth.

These effects must remain subtle and atmospheric. They should never become a game effect or decorative screen saver.

## World transition
Desired cycle:
Home → select direction → atmosphere changes → Orbit dissolves → selected world becomes fullscreen → internal interaction/scroll → world dissolves → Home returns → previous Orbit position is restored.

Especially liked concept: enter the photograph and let the selected image become the world.

## Current homepage prototype
Working branch for the homepage experiment: `feat/homepage-v13`.
Current latest homepage file: `freedom-home-v14.html`.
Latest commit: `d46780522054a787320d25313e2a5ae9d433ca68` — `feat: create refined Orbit homepage with themed atmospheres`.

V14 currently:
- centers the Orbit explicitly;
- removes the visible branches image from the homepage composition;
- removes the top FreeDom brand/caption;
- keeps FreeDom in the center of the Orbit;
- keeps five translucent circular doors without photographs inside them;
- preserves angle-based drag, inertia, snap and keyboard controls;
- adds the themed atmospheric layer system above;
- retains fullscreen world transition and the real Rooms gallery;
- retains links into the existing availability map for room selection.

V14 is still an experimental homepage candidate. Do not replace `main/index.html` yet.

## Rooms
Use existing real room categories/data and preserve booking/availability logic. Known project categories include family room, double room with balcony, attic room, bungalow, sleeping place on balcony, standard hostel and economy hostel. Existing availability page: `availability_map_v3.html`. Do not invent a parallel booking system.

## Space
Existing cinematic Space must be reused, not recreated. The real `space-preview.html` implementation was restored into the working feature branch from the existing project. Do not replace it with a guessed page.

## Backend safety
Repository: `freedomsochi/FreedOm`
Supabase: `vutmbhsclmcfqqlzxqkc`

Do not break Auth, users/guests, rooms, bookings/availability, kitchen/orders, admin/dashboard, notifications, RLS, RPC/business logic or existing Space.

## Vercel
Project: `freed-om`.
Latest V14 preview deployment from commit `d46780522054a787320d25313e2a5ae9d433ca68` is READY.
Temporary share URL for the current V14 page:
`https://freed-11tcgrfkq-sergeyogorodnik19-3325s-projects.vercel.app/freedom-home-v14.html?_vercel_share=fhq5cOT9JgWx7VNKsnZbdDBQr1jx2ypA`
It is temporary and expires 2026-09-11.

## Production safety
`main/index.html` is not replaced by the homepage experiment yet. Validate the full visual/interaction system before merging or changing production.

## Non-negotiables
- Do not endlessly create versions without a concrete improvement.
- Do not rewrite working CRM/backend for visual convenience.
- Do not merge experimental work into `main` until tested.
- Do not invent content/data when existing project data exists.
- Phone is a primary scenario; do not merely shrink desktop.
- Preserve warm organic visual language, physical Orbit, atmospheric transitions, fullscreen worlds and enter/return metaphor.

## Final metaphor
**One living house, not a collection of unrelated pages.**

Homepage = entrance.
Orbit = path.
Each direction = a door into a part of FreeDom life.
Account = tool.

The interface should visually communicate:
**«Вот FreeDom. Куда хочешь пойти?»**