# FreeDom Rooms — 3D Spatial Design Brief

## Status
Approved visual direction as of 2026-10-04. This document is the reference for the next implementation chat/sprint.

## Core decision
The Rooms page is NOT a conventional room catalog and NOT a flat 2D card grid.

The primary interface is an interactive spatial model of the real FreeDom house and territory.

Visual reference approved by the user: cinematic top-down/isometric FreeDom environment with a dark glass interface, left-side floor navigation, glowing interaction points, right-side object card, light/dark toggle and handwritten lower-right phrase:

**«Здесь начинается твоя история...»**

The generated image is a visual-quality/style reference only. It is NOT the geometric source of truth. Geometry must come from the textual/architectural plan already established in the project and later from the real plan/photos.

## Required quality bar
Do not use primitive-looking boxes as the final visual result.

The target is a professionally designed 3D environment with the visual richness of a modern game/virtual-tour interface, approximately the level of 2010-era high-quality game environments rather than an early web/SVG prototype.

The model should feel like a real place viewed from above:
- believable building massing;
- roofs/walls/floors;
- paths and terrain;
- vegetation;
- pool/water;
- garden objects;
- lighting and shadows;
- depth and atmospheric perspective;
- coherent materials;
- smooth camera movement.

A procedural Three.js foundation is acceptable for prototyping. Final visual quality may later require real 3D assets/GLTF or professionally modelled geometry.

## Camera / interaction
The user should be able to interact with the map similarly to a modern digital map:
- drag/pan;
- zoom in/out;
- orbit/rotate the view;
- smooth camera movement;
- controlled maximum/minimum zoom;
- no accidental camera jumps;
- selected object becomes the camera target.

Default presentation is a beautiful elevated top-down/isometric view, not a flat orthographic floor plan.

## Spatial composition — MUST PRESERVE
The generated reference image is atmospherically useful, but its house layout is NOT accurate.

The real composition must follow the known FreeDom plan:

**Bottom of the map:** entrance gates.

From the gates:
- the main route leads toward the house;
- the house is central;
- the porch is on the RIGHT side of the house;
- a road/path goes DOWN/left from the house toward the training/sport zone;
- the swimming pool is to the RIGHT of this route;
- the summer kitchen is attached/adjacent to the house in the known position;
- garden/territory continues around the house.

Territory objects that must be represented visually:
- gates;
- house;
- porch;
- summer kitchen;
- pool;
- training/sport zone;
- bungalow;
- hammock;
- fountain;
- garden paths;
- other already confirmed territory elements when their position is known.

Do not invent a new estate layout merely because it looks attractive.

## House model
The house must be constructed from the already established textual plan.

Known levels:
- −1 floor;
- 1st floor;
- 2nd floor;
- 3rd floor;
- attic.

The model must preserve:
- outer walls;
- internal rooms;
- corridors;
- stairwell;
- doors/openings where known;
- balconies where known;
- common areas;
- room locations;
- relationship between levels.

The exact dimensions are NOT yet authoritative unless supported by a real architectural plan. Do not invent measurements and present them as real.

## Floor navigation
Left side of screen:

**Пространство**
- whole territory + whole house;
- no destructive zoom into one object when this is selected;
- this is the overview/world state.

Then:
- Мансарда;
- 3 этаж;
- 2 этаж;
- 1 этаж;
- −1 этаж.

When a floor is selected:
- camera smoothly approaches the house/floor;
- selected floor remains visually readable;
- other levels become dim/translucent rather than disappearing abruptly;
- model still feels like one building.

When «Пространство» is selected:
- show the complete territory;
- do not zoom into the house just because Space is selected.

## Object selection
Interactive points must be visible on relevant objects.

The point should:
- be small;
- glow softly;
- pulse subtly;
- clearly indicate where to click;
- not look like a game combat marker.

Clicking the point/object:

`overview → camera move → close-up → card`

The camera should travel smoothly from above toward the selected object.

At maximum useful proximity:
- the selected object is the visual center;
- surrounding context remains partially visible;
- the information card appears only AFTER selection/camera movement begins or reaches its close state.

There must be NO permanently visible room information panel covering the map.

## Object card
Desktop: right side.
Mobile: bottom sheet.

Card contents:
- real photo;
- object name;
- floor / category;
- short description;
- capacity;
- booking mode;
- current availability when connected;
- current price from authoritative source when confirmed;
- **Забронировать**.

The card is a continuation of the spatial exploration, not a generic modal.

## Light / atmosphere
Keep the approved visual idea:
- dark cinematic mode by default;
- warm architectural light;
- soft green vegetation;
- water reflections;
- subtle night/day or light-theme toggle;
- no neon cyberpunk treatment.

## Interface
Keep the approved elements from the generated reference:
- FreeDom logo/name at upper left;
- «Вернуться на главную»;
- left floor/space navigation;
- top-right light/dark toggle;
- right-side selected-object card;
- lower-right handwritten phrase;
- subtle compass/interaction hints if useful.

The UI must remain subordinate to the model.

## Media
The 3D model does not need real photos embedded into its geometry.

Photos appear in the selected-object card.

Later we can support:
- gallery;
- short video;
- 360° view;
- interior walkthrough.

## Architecture/data separation
The 3D model is presentation geometry.

Existing Supabase room records remain the source of truth for sellable accommodation.
Do not duplicate booking logic in the 3D layer.

Use mapping such as:

`3D hotspot → room_id → rooms catalog → availability → existing booking flow`

Territory objects that are not bookable may map to informational content instead.

## Development stages
### Foundation V1
- professional-looking procedural 3D terrain;
- house massing;
- floor slabs/walls;
- stairs;
- gates;
- paths;
- pool;
- summer kitchen;
- sport zone;
- bungalow;
- hammock;
- fountain;
- camera controls;
- floor navigation;
- hotspots;
- close-up camera animation;
- object card.

### Accuracy V2
Replace approximate geometry with exact geometry from the real architectural plan and verified photographs.

### Visual V3
Improve materials, vegetation, roofs, windows, doors, furniture silhouettes, lighting, shadows and atmospheric depth.

### Integration V4
Connect hotspots to real room IDs, photos, availability, prices and existing booking flow.

## Non-negotiables
- Do not restart the Rooms architecture.
- Do not turn the page into a card catalog.
- Do not use the generated image as an exact floor plan.
- Do not invent geometry that conflicts with the established textual plan.
- Do not break existing FreeDom Space, CRM, Supabase or booking logic.
- Do not merge the foundation prototype into production before visual review.
- Real photos and real architectural data override visual assumptions.
