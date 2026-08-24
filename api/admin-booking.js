const SUPABASE_URL = process.env.SUPABASE_URL || 'https://vutmbhsclmcfqqlzxqkc.supabase.co';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'sb_publishable_G7jiYh_r-oC9gkd1a09Ncw_5BKgfV_q';
const ADMIN_EMAIL = 'serzh.xz@mail.ru';

export default async function handler(req, res) {
  if (req.method === 'GET') {
    return res.status(200).json({ ok: true, configured: Boolean(SUPABASE_ANON_KEY) });
  }

  if (req.method !== 'POST') {
    res.setHeader('Allow', 'GET, POST');
    return res.status(405).json({ ok: false, error: 'GET or POST required' });
  }

  const authHeader = req.headers.authorization || '';
  const accessToken = authHeader.startsWith('Bearer ') ? authHeader.slice(7).trim() : '';
  if (!accessToken) {
    return res.status(401).json({ ok: false, error: 'Требуется авторизация' });
  }

  try {
    const userResponse = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${accessToken}`,
      },
    });
    if (!userResponse.ok) {
      return res.status(401).json({ ok: false, error: 'Недействительная сессия' });
    }
    const user = await userResponse.json();
    if ((user.email || '').toLowerCase() !== ADMIN_EMAIL) {
      return res.status(403).json({ ok: false, error: 'Доступ запрещён' });
    }

    const { booking_id, action } = req.body || {};
    if (!booking_id || !['confirm', 'cancel'].includes(action)) {
      return res.status(400).json({ ok: false, error: 'booking_id and valid action are required' });
    }

    const rpc = action === 'confirm' ? 'confirm_booking' : 'cancel_booking';
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${rpc}`, {
      method: 'POST',
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${accessToken}`,
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
