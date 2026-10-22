# FreeDom Rooms — Verified Architectural Plan

> Source: user's hand-drawn plans provided in chat on 2026-10-04. This document records only information explicitly confirmed by the user. It is the authoritative geometry reference for the next Rooms 3D modelling stage until a measured architectural drawing is supplied.

## Purpose
The Rooms 3D model must stop using a generic rectangular house. Each level is to be reconstructed from the user's sketches and then assembled vertically into one building. The generated cinematic image remains a visual-quality reference only; it does not define geometry.

## Territory / site plan
Orientation used in the user's sketch:
- bottom = gates / site entrance;
- path leads from the gates toward the house;
- house is central;
- porch is on the right side of the house;
- a road/path runs down toward the sport/training zone;
- swimming pool is to the right of this route;
- summer kitchen is adjacent to the house in the known position;
- sport zone is a separate area and contains a kettlebell, pull-up bar and equipment for push-ups;
- pond is in the upper-left garden area near the trees;
- bungalow is in the upper part of the territory;
- hammock is in the garden area;
- fountain is in the garden area;
- sauna / bath is INSIDE the main house on the −1 floor; it is not a separate territory building.

### Territory object semantics
- **Sport zone** is one spatial object/zone, not one kettlebell object. The visible equipment includes a kettlebell, pull-up bar and push-up equipment.
- **Pool** is the rectangular object drawn to the right of the house/route.
- **Sauna / bath** is an internal room of the main house on −1; do not create a separate sauna building on the site.
- **Pond** is the water feature drawn beside the trees in the upper-left part of the site.

## Room-by-room navigation — latest user-confirmed product brief (2026-10-23)

This section records the current Rooms interface requirements and takes precedence over older summaries when assigning bookable accommodation to UI categories. Keep the original hand-drawn sketches as the geometry source; do not infer precise dimensions from the cinematic reference image.

- **−1 floor:** internal lower level; bath/sauna and kitchen/summer-kitchen zones remain inside the house, plus the areas visible in the sketch. These are not separate territory buildings.
- **1st floor:** living room, kitchen, circulation, sanitary area, stairs and the separately identified closed veranda, as confirmed in the architectural notes.
- **2nd floor:** economy hostel and living room in the current product brief. Preserve separate zones and mark the living room as non-bookable. The source sketch/older notes also label two separate standard-hostel spaces, administration, family room and sanitary zone; do not silently combine these with the current floor assignment. Validate the exact floor numbering against the original sketch before final geometry is approved.
- **Standard hostel:** there are **two separate standard-hostel rooms on the same floor**. They must be two independent selectable objects/cards, each with its own photo and availability mapping, not a single combined “Хостел стандарт” object.
- **3rd floor:** family room, administration and standard-hostel placement must follow the user's latest floor allocation once reconciled against the sketch; administration is not bookable. The yoga hall is shown in the hand-drawn plan for an upper level and must not be moved based on the visual reference alone.
- **4th floor / upper guest level:** two separate two-person rooms plus the yoga hall, per the user's latest product brief. Treat the rooms as separate selectable objects.
- **Attic / mansard:** **two separate rooms**, per explicit user confirmation on 2026-10-23. Do not represent the attic as one combined room.
- **Bungalow:** separate territory accommodation object, not a house floor.
- **Shared/decorative areas:** should remain visible on the floor plan, but must not be presented as bookable accommodation.

### Interface requirements for the Rooms page

The desired reference is the user's uploaded FreeDom Rooms screenshot (2026-10-23): retain the existing sunlit territory as a fixed background, three room preview cards on the left, a central glass panel, selected room details/gallery and booking action on the right, and a bottom horizontal floor selector.

- The territory/background must remain unchanged when the selected floor changes.
- Only the **internal floor plan** inside the central panel changes on floor selection.
- Use the floor selector for −1, 1, 2, 3, 4 and mansard where needed; if the design intentionally omits 4 from the visible selector, document how the upper guest level is accessed rather than hiding it.
- Click/tap a room polygon or hotspot to select the matching room card and detail panel.
- Distinguish bookable rooms from shared/non-bookable zones visually.
- Each physical room is its own record, even if multiple rooms share the same type or similar photographs.
- Date availability comes from the existing live availability endpoint. Never infer availability from the floor plan or image. If status cannot be loaded, show “не удалось проверить” / unknown rather than “свободно”.
- Keep the current frosted-glass eco-futuristic visual style and ensure the interface works on mobile without overlapping panels.
- Preserve the existing category filter and Telegram booking flow unless a separately reviewed change is approved.

### Source PDF inventory (uploaded 2026-10-23)

The source file “план дома чертеж(2).pdf” has 14 pages. It is image-based (no extractable text), so future work should inspect the relevant page images rather than rely on OCR or memory. The PDF includes:
- p.1: handwritten mansard sketch with two room labels and a yoga-hall label (handwriting is partially unclear);
- p.2: aerial photograph of the territory;
- p.3: FreeDom tree/space visual reference;
- p.4: the target Rooms UI reference screenshot;
- p.5: kitchen UI reference;
- p.6: handwritten upper-floor sketch marked “3 этаж”, with a large yoga/practice hall and side rooms;
- p.7: handwritten sketch marked “2 этаж”, showing two separate standard-hostel rooms, family room, administration and circulation/stair zone;
- p.8: handwritten sketch marked “−1 этаж”, showing internal kitchen/sauna/bath/pool-related zones;
- p.9: handwritten first-floor sketch;
- pp.10–14: real photographs of the territory, balcony and house exterior.

Because the PDF is image-based, this Markdown document is the searchable summary, not a replacement for exact measurements or every line in the drawing. If precise wall placement is needed, inspect the rendered source pages. Do not claim that the original PDF is permanently embedded in GitHub unless it is separately committed as an asset.

## Building levels
The house has the following levels:
- −1 floor
- 1 floor
- 2 floor
- 3 floor
- attic / upper level

The model must preserve different footprints and internal layouts where shown in the sketches. Do not force every floor into the same rectangle.

## −1 floor
The hand-drawn plan shows a lower level INSIDE the main house containing:
- pool-related area;
- kitchen / summer-kitchen area in the north part;
- sauna / shower-related area;
- terrace;
- stair connection.

Some handwritten labels are not fully legible in the photograph. Do not invent names for unreadable rooms. Preserve their geometry and mark their semantic label as pending until confirmed.

## 1 floor — confirmed layout
The first-floor sketch contains:
- living room / **Гостиная**;
- kitchen / **Кухня**;
- corridor / circulation area;
- bathroom/toilet area;
- stairs / stair connection;
- **closed veranda / Закрытая веранда** — the previously unlabeled zone at the upper part of the first-floor sketch. The user explicitly confirmed that this is a closed veranda.

The closed veranda is a distinct architectural space and must not be merged visually into the living room.

## 2 floor — confirmed layout
The user explicitly clarified the main room semantics:
- **left = standard hostel**;
- **right = standard hostel**;
- **upper-left = admin / administration**;
- **upper-right = family room**;
- **upper area = bathroom/sanitary zone**, according to the sketch;
- central area = circulation/corridor and stair connection.

The two standard hostel areas are separate selectable accommodation objects in the future 3D interface. The family room is a separate selectable accommodation object. Administration is not a bookable guest room.

## 3 floor — confirmed from sketch
The sketch shows:
- a large central/upper practice space labelled for **yoga**;
- rooms/zones on the sides;
- stair connection;
- balcony in the upper part;
- additional side area(s).

Only the labels clearly readable/confirmed from the source should be treated as authoritative. Unreadable handwritten room names remain pending.

## Attic
The project navigation includes an attic level. The detailed attic topology is present in the broader project material, but the current hand-drawn sheet shown in this conversation does not provide enough readable detail to redefine it. Do not invent a new attic layout from the current image alone.

## 3D construction rules
1. Build each floor as an independent 2D architectural footprint first.
2. Convert each footprint into walls, openings, slabs and stairs.
3. Stack the levels vertically only after each footprint is validated.
4. Keep the territory model separate from the internal building model.
5. Preserve real relative positions from the user's sketches even when exact metric dimensions are unknown.
6. Do not use decorative geometry to hide incorrect room topology.
7. Do not treat the generated reference image as an architectural drawing.
8. If a dimension is unknown, use a proportional placeholder and mark it as non-authoritative rather than inventing a measurement.
9. Final visual quality target is a professional 3D spatial environment with substantial depth, materials, lighting and architectural detail — not primitive cubes.
10. Keep the existing Rooms UX: left floor navigation, Space mode, interactive hotspots, camera approach, object card, booking action, return-to-home and light toggle.

## Validation rule
Before adding high-detail art, the user should be able to inspect the model from above and confirm:
- site object positions;
- building footprint;
- each floor footprint;
- room adjacency;
- stairs;
- veranda;
- two standard hostels on level 2;
- administration and family room on level 2;
- sanitary area;
- yoga/practice area on level 3;
- territory objects.

Only after this structural approval should the model move into the high-detail visual pass.
