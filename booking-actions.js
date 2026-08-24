/* FreeDom — admin booking actions */
(function(){
  const SUPABASE_URL = window.SUPABASE_URL || '';
  const SUPABASE_ANON_KEY = window.SUPABASE_ANON_KEY || '';
  async function callRpc(name, bookingId){
    if(!SUPABASE_URL || !SUPABASE_ANON_KEY) throw new Error('Supabase configuration is missing');
    const r = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${name}`, {
      method:'POST',
      headers:{'Content-Type':'application/json','apikey':SUPABASE_ANON_KEY,'Authorization':`Bearer ${SUPABASE_ANON_KEY}`},
      body:JSON.stringify({p_booking_id:bookingId})
    });
    const data = await r.json().catch(()=>null);
    if(!r.ok) throw new Error(data?.message || data?.hint || data?.error || 'Не удалось изменить статус заявки');
    return data;
  }
  window.FreeDomBookingActions = {
    confirm: id => callRpc('confirm_booking', id),
    cancel: id => callRpc('cancel_booking', id)
  };
})();