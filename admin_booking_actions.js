/* FreeDom CRM — pending booking actions. Uses the existing page-level Supabase client. */
(function(){
  const style=document.createElement('style');
  style.textContent='.booking-pending-actions{display:flex;gap:8px;flex-wrap:wrap;margin-top:12px}.booking-pending-actions button{border:0;border-radius:10px;padding:9px 12px;font:inherit;font-weight:700;cursor:pointer}.booking-confirm{background:#dff5ed;color:#246b58}.booking-cancel{background:#fff0ed;color:#8b463d}.booking-pending-label{display:inline-flex;align-items:center;gap:6px;padding:6px 9px;border-radius:10px;background:#fff7df;color:#80662c;font-size:12px;font-weight:700}';
  document.head.appendChild(style);
  async function act(id,method,btn){
    if(!window.db||typeof window.db.rpc!=='function'){alert('Не найдено подключение Supabase админки');return}
    btn.disabled=true; const old=btn.textContent; btn.textContent='Обработка…';
    try{const {error}=await window.db.rpc(method,{p_booking_id:id});if(error)throw error;window.location.reload()}catch(e){alert(e.message||'Не удалось изменить заявку');btn.disabled=false;btn.textContent=old}
  }
  function enhance(){
    const list=document.getElementById('list'); if(!list)return;
    const cards=[...list.querySelectorAll('.booking[data-booking-id]')];
    cards.forEach(card=>{
      if(card.dataset.bookingActionsReady==='1')return;
      const status=(card.dataset.bookingStatus||'').trim().toLowerCase();
      const id=card.dataset.bookingId;
      if(!id||!['новое','new','pending'].includes(status))return;
      card.dataset.bookingActionsReady='1';
      const box=document.createElement('div');box.className='booking-pending-actions';
      const label=document.createElement('span');label.className='booking-pending-label';label.textContent='🟡 Ожидает подтверждения';
      const yes=document.createElement('button');yes.className='booking-confirm';yes.textContent='✓ Подтвердить';yes.onclick=()=>act(id,'confirm_booking',yes);
      const no=document.createElement('button');no.className='booking-cancel';no.textContent='× Отменить';no.onclick=()=>act(id,'cancel_booking',no);
      box.append(label,yes,no);card.appendChild(box);
    });
    const pending=cards.filter(c=>c.dataset.bookingStatus==='новое'||c.dataset.bookingStatus==='new'||c.dataset.bookingStatus==='pending');
    if(pending.length){
      pending.reverse().forEach(card=>list.prepend(card));
    }
  }
  const obs=new MutationObserver(enhance);obs.observe(document.body,{childList:true,subtree:true});window.addEventListener('load',enhance);setTimeout(enhance,700);
})();