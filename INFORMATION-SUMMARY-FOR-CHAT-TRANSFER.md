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
Current homepage file: `freedom-home-v14.html`.

V14 currently:
- centers the Orbit explicitly;
- hides all five portals on initial load;
- shows only FreeDom in the center initially;
- clicking FreeDom blooms the five portals into view;
- keeps FreeDom wordmark contained on mobile;
- keeps five translucent circular doors without photographs inside them;
- preserves angle-based drag, inertia, snap and keyboard controls;
- adds the themed atmospheric layer system above;
- retains the internal world system for the other directions and the real Rooms gallery;
- retains links into the existing availability map for room selection.

### Space entry — completed current stage
The **Пространство** portal now has a dedicated cinematic entry animation rather than opening the generic internal world sheet.

Sequence:
1. User opens the Orbit with FreeDom.
2. User selects **Пространство**.
3. The selected portal expands dramatically from its circular door into the screen.
4. The Orbit/core/labels dissolve and a restrained «Пространство» title appears during the transition.
5. After the animation, browser navigation goes to the existing real `space-preview.html` page.
6. The existing Space page is reused unchanged as the destination; it is not recreated.

The transition is implemented in V14 with `.space-launch` animation and `openSpace()` navigation. Vercel share query parameters are preserved when navigating to `space-preview.html` so the preview can remain accessible when testing through a temporary share URL.

Important deployment limitation discovered during verification: direct requests to `space-preview.html` on the Vercel preview currently return a Vercel SSO/302 protection response (`X-Frame-Options: DENY`). Therefore the cinematic transition code is complete, but anonymous public access to the Space destination still needs to be resolved at the Vercel deployment-protection level before this can be considered production-public. Do not rebuild Space to work around this; fix the hosting/protection configuration or use the existing project architecture.

The homepage root problem was also diagnosed: Vercel `rewrites` did not override the existing root `index.html`. `vercel.json` now uses a root **redirect** to `/freedom-home-v14.html`, while `main/index.html` remains untouched as an implementation file.

Latest relevant commits on `feat/homepage-v13` include:
- `b7c30e951cf8294a46368df8a71264e99ff18e0c` — `feat: add cinematic Space entry transition`
- `358e5afca4a4f24a67b152f6f29349e1af0cb0aa` — `fix: redirect Orbit root to V14 homepage`
- `6cd64d71aa182460657d23474c26a74735b4ee7b` — `fix: preserve preview access when entering Space`
- the temporary patch workflows used for these one-off edits have been removed after execution.

## Space
Existing cinematic Space must be reused, not recreated. The real `space-preview.html` implementation was restored into the working feature branch from the existing project. Do not replace it with a guessed page.

## Logo asset for future homepage refinement
There is an existing GitHub logo asset named **`логотип.png`** with an alpha channel. The user specifically wants to consider it as the central visual element when the Orbit is opened/entered. It has not been incorporated blindly yet because the current stage is to finish the Space transition first. The next chat should inspect the actual asset from GitHub and decide whether it should replace or sit behind/inside the central FreeDom element.

The user explicitly does NOT want to upload this asset to chat; inspect it directly from GitHub when possible.

## Next project stage after Space
Do not restart the project. The intended handoff is:
1. Finish/verify the Space entry and hosting access.
2. Move to the next chat.
3. New chat should read this summary, inspect the current GitHub/Vercel state and the actual site.
4. It should then propose visual/image directions for the homepage based on the existing design rather than inventing a new concept.
5. Implement those selected visual improvements and only then continue refining the remaining worlds, starting with Rooms after Space is solid.

## Rooms
Use existing real room categories/data and preserve booking/availability logic. Known project categories include family room, double room with balcony, attic room, bungalow, sleeping place on balcony, standard hostel and economy hostel. Existing availability page: `availability_map_v3.html`. Do not invent a parallel booking system.

## Backend safety
Repository: `freedomsochi/FreedOm`
Supabase: `vutmbhsclmcfqqlzxqkc`

Do not break Auth, users/guests, rooms, bookings/availability, kitchen/orders, admin/dashboard, notifications, RLS, RPC/business logic or existing Space.

## Vercel
Project: `freed-om`.
Homepage experiment branch: `feat/homepage-v13`.
The latest verified READY deployment containing the Space-share patch is currently the deployment from commit `6cd64d71aa182460657d23474c26a74735b4ee7b` (`dpl_9HWRC4ewwVr16Gk71qjB8wfoXDRz`). A newer deployment from the workflow-removal commit is building and will supersede it.

A temporary share URL was generated for testing:
`https://freed-k7vdnuw2e-sergeyogorodnik19-3325s-projects.vercel.app/?_vercel_share=sPxdOhCzWGmI6BpQKQuzKIBLwxFCYcfy`
It is temporary and expires 2026-09-11.

## Production safety
`main/index.html` is not replaced by the homepage experiment. The V14 experiment remains isolated on `feat/homepage-v13`.

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