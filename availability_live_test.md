# Live availability integration test

The availability map should call `POST /api/availability` with:

```json
{"check_in":"2026-08-25","check_out":"2026-08-28"}
```

The Vercel route forwards the request server-side to the protected Supabase `public-availability` Edge Function. No service-role key is exposed to the browser.

Expected response fields per room:

- `id`
- `name`
- `capacity`
- `booking_mode`
- `available`
- `free_places`

Prices remain intentionally non-authoritative until the current prices are supplied.
