/* FreeDom Admin — guest events module
   Usage: include this file after Supabase client is initialized, then call:
   FreeDomGuestEvents.render({ userId, targetId: 'guestEvents' })
*/
(function () {
  const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({ '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;' }[c]));
  const money = n => (Number(n) || 0).toLocaleString('ru-RU') + ' ₽';
  const statusText = s => ({ new:'Новая', confirmed:'Подтверждена', cancelled:'Отменена' }[s] || s || 'Новая');
  const paymentText = (x) => {
    if ((Number(x.amount) || 0) <= 0) return 'Бесплатно';
    const paid = Number(x.paid_amount) || 0, amount = Number(x.amount) || 0;
    if (paid >= amount) return 'Оплачено';
    if (paid > 0) return 'Частично оплачено';
    return 'Не оплачено';
  };
  const dateTime = (d, t) => {
    if (!d) return '—';
    const dt = new Date(d + (t ? 'T' + t : 'T00:00:00'));
    return dt.toLocaleString('ru-RU', { day:'2-digit', month:'2-digit', year:'numeric', hour:t ? '2-digit' : undefined, minute:t ? '2-digit' : undefined });
  };

  async function render({ userId, targetId }) {
    const target = document.getElementById(targetId);
    if (!target || !userId || !window.sb) return;
    target.innerHTML = '<div class="muted">Загрузка событий…</div>';
    const { data, error } = await window.sb
      .from('event_registrations')
      .select('id,event_id,guest_name,guest_phone,guest_email,participants,amount,paid_amount,status,payment_status,comment,created_at,events(name,event_date,start_time,end_time,location,price)')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    if (error) {
      target.innerHTML = '<div class="muted">Не удалось загрузить события: ' + esc(error.message) + '</div>';
      return;
    }
    const rows = data || [];
    if (!rows.length) {
      target.innerHTML = '<div class="muted">🎫 Записей на события пока нет.</div>';
      return;
    }
    target.innerHTML = '<h3>🎫 События</h3>' + rows.map(x => {
      const e = x.events || {}, amount = Number(x.amount) || 0, paid = Number(x.paid_amount) || 0, debt = Math.max(0, amount - paid);
      return `<div class="guest-event" style="background:#0e1120;border:1px solid #252941;border-radius:12px;padding:12px;margin-top:10px">
        <div style="display:flex;justify-content:space-between;gap:10px;flex-wrap:wrap"><b>${esc(e.name || 'Событие')}</b><span>${esc(statusText(x.status))}</span></div>
        <div class="muted" style="margin-top:5px">📅 ${esc(dateTime(e.event_date, e.start_time))}${e.location ? ' · 📍 ' + esc(e.location) : ''}</div>
        <div style="margin-top:8px">👥 ${Number(x.participants) || 1} · 💰 ${amount ? money(amount) : 'Бесплатно'}</div>
        <div style="margin-top:5px">💳 ${esc(paymentText(x))}${amount > 0 ? ' · оплачено ' + money(paid) + (debt ? ' · <b class="red">долг ' + money(debt) + '</b>' : '') : ''}</div>
        ${x.comment ? '<div class="muted" style="margin-top:5px">💬 ' + esc(x.comment) + '</div>' : ''}
      </div>`;
    }).join('');
  }

  window.FreeDomGuestEvents = { render };
})();