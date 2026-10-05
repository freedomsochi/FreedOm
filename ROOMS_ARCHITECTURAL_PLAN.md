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
- the summer kitchen is NOT a separate territory building; latest user correction places it **inside the house on the north part of the −1 floor**;
- sport zone is a separate area and contains a kettlebell, pull-up bar and equipment for push-ups;
- pond is in the upper-left garden area near the trees;
- bungalow is in the upper part of the territory;
- hammock is in the garden area;
- fountain is in the garden area;
- sauna is NOT a separate territory object; latest user correction places the **bath/sauna inside the house on the −1 floor**.

### Territory object semantics
- **Sport zone** is one spatial object/zone, not one kettlebell object. The visible equipment includes a kettlebell, pull-up bar and push-up equipment.
- **Pool** is the rectangular object drawn to the right of the house/route.
- **Sauna** is a separate object whose detailed geometry is not final yet.
- **Pond** is the water feature drawn beside the trees in the upper-left part of the site.

## Building levels
The house has the following levels:
- −1 floor
- 1 floor
- 2 floor
- 3 floor
- attic / upper level

The model must preserve different footprints and internal layouts where shown in the sketches. Do not force every floor into the same rectangle.

## −1 floor — latest confirmed correction
The −1 floor is **inside the main house**. The latest user correction overrides the older territory interpretation:
- **summer kitchen** — inside the house, in the **north part of the −1 floor**;
- **bath/sauna** — inside the house, on the −1 floor;
- other −1 floor rooms remain according to the user's original hand-drawn plan;
- terrace and stair connection remain where shown by the plan;
- pool-related area remains part of the −1 floor model where shown by the plan.

Do not represent the summer kitchen or bath/sauna as separate buildings on the territory.

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
- territory objects, with no separate summer-kitchen or sauna building.

Only after this structural approval should the model move into the high-detail visual pass.
