# Availability API

`POST /api/availability` is a server-side Vercel proxy for the protected Supabase `public-availability` Edge Function.

Required Vercel environment variables:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Both must be configured server-side in Vercel. Never put the service-role key in HTML, client JavaScript, or GitHub.
