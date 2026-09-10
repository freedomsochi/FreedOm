# FreeDom V14 — context and current design state

## Purpose

This document preserves the decisions and technical state of the V14 homepage so future work continues from the existing project rather than recreating the concept.

## Product idea

FreeDom is a living home and community, not a conventional hotel website, SaaS dashboard, game menu, spaceship or sterile luxury interface.

Core phrase:

> FreeDom — дом, в котором есть жизнь.

The homepage should feel like looking into a living world: **«Что здесь происходит? Хочу заглянуть внутрь.»**

The interface should communicate the real atmosphere through real FreeDom places, people and activities rather than abstract marketing copy.

## Orbit architecture

The homepage has one central FreeDom core and five directions:

1. Пространство
2. Кухня
3. Баня
4. События
5. Комнаты

The account is separate and subtle; it is not an Orbit direction.

The five portals form one regular pentagon around the central FreeDom core. They must remain geometrically symmetrical: equal angular spacing (72°), one common radius, one common center, and visually balanced clearance from both the central core and the outer Orbit boundary.

Real FreeDom photography is used. No stock imagery. The existing `images/branches.png` asset is part of the visual language.

## Visual direction

Warm organic glassmorphism: wood, red brick, greenery, water, sunlight, transparent glass, blur and depth.

Avoid cold sci-fi/cyberpunk, spaceship, game-menu, SaaS and sterile hotel-card aesthetics.

Mobile is the primary target.

## Interaction model

Orbit supports pointer/finger rotation with drag and inertia, slowdown and snapping. Labels stay readable. The selected portal becomes more material/brighter without aggressive glow.

Current behavior:

- The user opens Orbit.
- The five portals appear around the central core.
- Selecting a portal rotates the Orbit so the selected portal moves to the **bottom-center position**. This is the intended selection zone for the next interaction.
- The selected portal should be clearly emphasized and then explicitly activated by a deliberate tap/click rather than immediately opening a world on the first selection.
- The Space direction is currently a special case: its transition to the existing Space experience is already implemented and working.

## Selection vs immediate opening — design decision

Preferred model: **select first, activate second**.

Reasoning:

1. Immediate opening is visually fast, but accidental taps become navigation events. On a tactile/mobile interface this creates unnecessary back-and-forth.
2. Selection-first gives the Orbit a clear two-stage interaction: first orient yourself, then enter.
3. The selected portal can receive a short, cinematic visual cue: increased materiality/brightness, subtle scale or depth change, a restrained pulse/ring, and a clear invitation to tap.
4. This preserves the feeling that the user is exploring a living space rather than operating a conventional menu.
5. The interaction can still feel fast if the selection animation is short (roughly 400–800 ms) and the second tap immediately opens the selected world.

The exact visual language of the selected state is intentionally **not final**. It should be designed experimentally on **Пространство** first, then generalized to the other four directions only after the Space prototype feels right.

## World transition

Conceptually:

Home → Orbit → select direction → selected state → deliberate activation → selected world fullscreen → internal interaction → world dissolves → Home returns with previous Orbit position restored.

The existing Space implementation should be reused rather than recreated.

## Current technical state

- Current experimental branch: `feat/homepage-v13`.
- Current homepage file: `freedom-home-v14.html`.
- Space transition works.
- Orbit portal geometry has been iteratively corrected to a regular pentagon with a common center/radius.
- A recent geometry fix removed conflicting center-position overrides and restored explicit portal coordinates.
- The current selection fix changes the snap target so the selected portal is positioned at bottom-center instead of rotating to an empty/top area.

## Next design experiment: Пространство

Do not redesign the whole homepage yet.

Use **Пространство** as the single experimental window/world for defining the language of selected-state feedback and window entry. Test:

- how the selected portal announces itself;
- how long the selection animation should last;
- how the second tap/click is communicated;
- whether the transition should expand from the selected circle or dissolve the Orbit around it;
- how the real Space content enters without feeling like a page change;
- how returning to Orbit restores the user's previous orientation.

Only after this interaction is visually convincing should the same pattern be propagated to Кухня, Баня, События and Комнаты.

## Do not break

Do not replace the existing FreeDom concept with a new concept. Do not rewrite the backend or existing authentication, users, guests, rooms, bookings, availability, kitchen/orders, admin/dashboard, notifications, RLS or RPC business logic while experimenting with V14 visual interaction.

Do not merge the experimental homepage into `main` until it has been visually validated.
