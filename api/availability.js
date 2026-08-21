const SUPABASE_URL = 'https://vutmbhsclmcfqqlzxqkc.supabase.co';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ ok: false, error: 'POST required' });
  }

  try {
    const response = await fetch(`${SUPABASE_URL}/functions/v1/public-availability`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
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
