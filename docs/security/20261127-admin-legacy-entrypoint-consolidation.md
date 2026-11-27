# Admin legacy entrypoint consolidation — 2026-11-27

## Why
A follow-up scan of the complete branch tree found older HTML pages outside the current CRM navigation. Several still contained direct reads of guest, booking, order, payment and finance tables, and some used a fixed-email client-side access check. They were not all linked from the current CRM, but the legacy finance panel remained reachable from the current finance screen.

## Source-only changes
The following old URLs now redirect to the current protected screens. The files are retained; nothing was deleted.

| Legacy entry point | New destination |
| --- | --- |
| `admin.html` | `admin_v10_dashboard.html` |
| `admin_payments.html` | `admin_v10_finance.html` |
| `admin_v10_guest.html` | `admin_guest_profile.html` (preserves query string) |
| `admin_v10_guest_profile.html` | `admin_guest_profile.html` (preserves query string) |
| `admin_v12_guest_profile.html` | `admin_guest_profile.html` (preserves query string) |
| `admin_bookings_v2.html` | `admin_v13_bookings.html` (preserves query string) |

The legacy-finance link was removed from `admin_v10_finance.html`; it now links back to the current CRM dashboard.

## Canonical paths verified
- `admin_guest_profile.html` loads `guest_profile.js`, which uses `admin_get_guest_profile` rather than direct table reads.
- The profile UI checks `data.can_record_payments` before displaying the payment form.
- `admin_v13_bookings.html` is the current booking workspace wrapper for the map, requests and occupancy tabs.
- `admin_v11_guest_profile.html` and `admin_v13_guest_profile.html` already act as aliases to the canonical protected profile.

## Static checks
Ten checks passed:
1. Legacy admin and payments entrypoints redirect and contain no direct table reads.
2. Three legacy guest-profile pages redirect and contain no direct table reads.
3. Legacy booking page redirects and contains no direct table reads.
4. Current finance page no longer links to `admin.html`.
5. Canonical profile uses the protected profile RPC and has no direct table reads.
6. Payment form is gated by the owner capability flag.
7. Canonical profile page loads the updated profile script.
8. Booking workspace still includes the current map, requests and occupancy screens.
9. Existing guest-profile alias still points to the canonical profile.

## Important limits
These redirects reduce accidental access to stale code paths; they are not a substitute for database authorization. Direct URL access to RPCs/tables remains controlled by RLS, function guards and grants. The work is source-only. No production SQL, deployment or file deletion was performed.
