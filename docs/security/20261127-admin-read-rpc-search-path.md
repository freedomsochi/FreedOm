# Admin read RPC search_path hardening

Date: 2026-11-27  
Branch: `fix/security-rpc-hardening-2026-11-26`  
Status: prepared on feature branch only; no live database changes.

This patch pins `search_path` for 12 existing authenticated admin SECURITY DEFINER functions to `pg_catalog, public`:

- `admin_get_bookings_overview()`
- `admin_get_finance_overview()`
- `admin_get_guest_dashboard_stats()`
- `admin_get_guest_profile(uuid)`
- `admin_get_guests_overview()`
- `admin_get_rooms()`
- `admin_get_space_location(text)`
- `admin_get_space_navigation()`
- `admin_get_space_overview()`
- `admin_get_user_debts()`
- `admin_get_users()`
- `admin_record_guest_payment(uuid,integer,text,text,uuid)`

The target functions already contain explicit administrator identity checks in their current live definitions. This migration changes only function configuration; it does not rewrite bodies, alter grants, modify RLS, or touch data. It aborts if any expected signature is missing or no longer SECURITY DEFINER.

Run the paired verification query in staging. Check admin pages for guest profile, finance, space, room and payment flows before production. This is defense-in-depth, not a replacement for the planned database role table.
