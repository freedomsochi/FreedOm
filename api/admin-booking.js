const SUPABASE_URL = process.env.SUPABASE_URL || 'https://vutmbhsclmcfqqlzxqkc.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ ok: false, error: 'POST required' });
  }

  if (!SUPABASE_SERVICE_ROLE_KEY) {
    return res.status(500).json({ ok: false, error: 'Admin booking service is not configured' });
  }

  const { booking_id, action } = req.body || {};
  if (!booking_id || !['confirm', 'cancel'].includes(action)) {
    return res.status(400).json({ ok: false, error: 'booking_id and valid action are required' });
  }

  const rpc = action === 'confirm' ? 'confirm_booking' : 'cancel_booking';

  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${rpc}`, {
      method: 'POST',
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ p_booking_id: booking_id }),
    });

    const text = await response.text();
    let body;
    try {
      body = JSON.parse(text);
    } catch {
      body = { ok: false, error: 'Invalid admin booking service response' };
    }

    return res.status(response.status).json(body);
  } catch (error) {
    console.error('admin booking proxy error', error);
    return res.status(502).json({ ok: false, error: 'Admin booking service unavailable' });
  }
}
