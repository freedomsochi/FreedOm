export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ ok: false, error: 'POST required' });
  }

  const functionUrl = `${process.env.SUPABASE_URL}/functions/v1/public-availability`;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!process.env.SUPABASE_URL || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'Server configuration error' });
  }

  try {
    const response = await fetch(functionUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${serviceKey}`,
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
