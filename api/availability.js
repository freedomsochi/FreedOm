const SUPABASE_URL = 'https://vutmbhsclmcfqqlzxqkc.supabase.co';
// Legacy anon key is intentionally public. It is only used to authenticate
// the request to the JWT-protected Edge Function; database access stays
// inside Supabase and is never performed from the browser.
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ1dG1iaHNjbG1jZnFxbHp4cWtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ1ODY1OTEsImV4cCI6MjEwMDE2MjU5MX0.PxvaHbwqJjOlStrr0HQx8xulR3BLPxzm4EQWl2LFu2c';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ ok: false, error: 'POST required' });
  }

  const functionUrl = `${SUPABASE_URL}/functions/v1/public-availability`;

  try {
    const response = await fetch(functionUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify(req.body ?? {}),
    });

    const text = await response.text();
    let body;
    try {
      body = JSON.parse(text);
    } catch {
      body = { ok: false, error: 'Invalid upstream response' };
    }

    return res.status(response.status).json(body);
  } catch (error) {
    console.error('availability proxy error', error);
    return res.status(502).json({ ok: false, error: 'Availability service unavailable' });
  }
}
