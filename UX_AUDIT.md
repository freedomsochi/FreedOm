# FreeDom CRM — UX Audit & UI 2.0

## Goal

Make the admin interface simple, calm, predictable and fast to operate without changing the existing business logic or database model.

## Core UX principle

The CRM should answer three questions immediately:

1. What needs attention now?
2. What action should I take?
3. Where can I see the complete history of this guest / booking / event / charge?

## Information architecture

### OPERATIONS
- Dashboard
- Guests
- Bookings
- Events

### SERVICE
- Kitchen
- Services

### FINANCE
- Finance

Settings can be added later without changing the main navigation model.

## Dashboard — target UX

The dashboard is the operational home screen, not a statistics wall.

Priority order:
1. Today / attention items
2. Quick actions
3. Current occupancy and bookings
4. Events and registrations
5. Financial attention / debts
6. Secondary analytics

Recommended quick actions:
- New booking
- New guest
- New event
- New kitchen order

Recommended attention cards:
- Arrivals today
- Departures today
- Unpaid / debt requiring attention
- New event registrations
- New kitchen orders

Existing dashboard already contains guests, active events, registrations, debt, upcoming events and registrations; these remain, but their hierarchy should become action-oriented.

## Guest profile — central CRM entity

A guest profile should connect:

Guest → Bookings → Events → Kitchen → Services → Finance

Top area:
- name
- phone / email
- current status
- total debt
- paid
- charged
- primary actions

Financial summary must answer:
- how much is owed
- what it is owed for
- what has already been paid

Breakdown:
- Accommodation
- Kitchen
- Events
- Services

Each outstanding charge should lead directly to its financial detail.

## Bookings — future FreeDom Space foundation

Keep the existing working booking logic.

Target UX:
- Today / Tomorrow / Select date
- Floor / Territory switching
- visual occupancy state
- free capacity rather than individual beds where appropriate
- click object → booking details → guest profile

Future territory layer:
- House
- Garden
- Pool
- Summer kitchen
- Outdoor gym
- Bungalow
- Pond + bridge
- Sauna
- Future sauna
- Hammock
- Future children's area

Photos must be treated as media slots, not structural dependencies. Real photos will be inserted after the spatial model is approved.

## Events

Events remain a separate first-class entity.

Required relationship:
Event → Registration → Guest profile
Guest profile → Events → Registration

Payment state is administrative state and remains manually controlled until automatic payment is available.

## Finance

Finance should prioritize:
- total charged
- total paid
- current debt
- overdue / attention

Then show the detailed ledger.

The most useful question is not only "how much?" but "who owes what and why?"

## Kitchen

Kitchen should be operational rather than accounting-heavy.

Recommended states:
- New
- Preparing
- Ready
- Completed / Archive

## Mobile UX

The CRM must be usable on a phone while an administrator is moving around the property.

Primary mobile flows:
- Guest → profile → debt
- Booking → guest
- Event → participants
- Kitchen → new order

Avoid forcing long desktop tables into narrow screens.

## Visual system

Keep the existing light glassmorphism direction.

Rules:
- glass is atmosphere, not the content itself
- primary action must remain visually obvious
- use mint/green for positive / available states
- red only for debt / attention
- lilac as a secondary accent
- avoid excessive decorative cards
- keep information density calm

## Important UX correction

Static cards should not visually "jump" on hover. Interactive rows and buttons may animate; informational cards should remain stable.

## Implementation order

1. Dashboard action hierarchy
2. Guest profile hierarchy and cross-links
3. Navigation grouping / consistency
4. Booking UX and FreeDom Space foundation
5. Finance attention workflow
6. Kitchen operational workflow
7. Mobile pass
8. Visual polish / micro-interactions
9. Real photography integration

## Photography rule

Do not block structural development waiting for photos.

When a real photo is needed, define the exact media slot and desired viewpoint first. The real image then replaces the placeholder/reference without changing the UX architecture.
