(function(){
  'use strict';
  const SUPABASE_URL='https://vutmbhsclmcfqqlzxqkc.supabase.co';
  const SUPABASE_KEY='sb_publishable_G7jiYh_r-oC9gkd1a09Ncw_5BKgfV_qC';
  const FORM_ENDPOINT='https://formspree.io/f/xpqgkzgo';
  const roomMap={
    family:['Семейная комната'],
    balcony:['Двухместный с балконом №1','Двухместный с балконом №2'],
    attic:['Мансардная комната №1','Мансардная комната №2'],
    bungalow:['Бунгало в саду'],
    balcony_bed:['Спальное место на балконе'],
    hostel_standart:['Хостел стандарт'],
    hostel_economy:['Хостел эконом']
  };
  if(!window.supabase) { console.error('FreeDom: Supabase library is not loaded'); return; }
  const sb=window.supabase.createClient(SUPABASE_URL,SUPABASE_KEY);

  async function createBooking(fd){
    const roomType=String(fd.get('room_type')||'');
    const checkin=String(fd.get('checkin')||'');
    const checkout=String(fd.get('checkout')||'');
    const guestName=String(fd.get('name')||'').trim();
    const phone=String(fd.get('phone')||'').trim();
    const email=String(fd.get('email')||'').trim();
    const adults=Math.max(1,Number(fd.get('adults')||1));
    const children=Math.max(0,Number(fd.get('children')||0));
    if(!roomMap[roomType]||!checkin||!checkout||!guestName||!phone) throw new Error('Заполните обязательные поля.');
    const start=new Date(checkin+'T00:00:00'), end=new Date(checkout+'T00:00:00');
    const nights=Math.round((end-start)/86400000);
    if(!Number.isFinite(nights)||nights<=0) throw new Error('Дата выезда должна быть позже даты заезда.');

    const {data:rooms,error:roomsError}=await sb.from('rooms').select('id,name,price_per_night').in('name',roomMap[roomType]);
    if(roomsError) throw roomsError;
    if(!rooms||!rooms.length) throw new Error('Выбранный тип номера не найден в базе.');

    const ids=rooms.map(r=>r.id);
    const {data:busy,error:busyError}=await sb.from('bookings').select('room_id,check_in_date,check_out_date,status').in('room_id',ids).lt('check_in_date',checkout).gt('check_out_date',checkin);
    if(busyError) throw busyError;
    const active=new Set(['новое','подтверждено','активна','долг']);
    const busyIds=new Set((busy||[]).filter(b=>active.has(String(b.status||'').toLowerCase())).map(b=>b.room_id));
    const room=rooms.find(r=>!busyIds.has(r.id));
    if(!room) throw new Error('На выбранные даты нет свободного номера этого типа.');

    const total=Math.round(Number(room.price_per_night||0)*nights);
    const payload={
      room_id:room.id,
      user_id:null,
      guest_name:guestName,
      guest_phone:phone,
      guest_email:email||null,
      check_in_date:checkin,
      check_out_date:checkout,
      status:'новое',
      services:{children,notes:String(fd.get('notes')||'').trim(),source:String(fd.get('source')||''),room_type:roomType},
      total_amount:total,
      guest_count:adults+children,
      discount_amount:0,
      paid_amount:0,
      payment_status:'не выбрано'
    };
    const {error}=await sb.from('bookings').insert(payload);
    if(error) throw error;
    return {total,room,nights};
  }

  async function handleBookingSubmit(e){
    const form=e.target;
    if(!form || form.id!=='bookingForm' || form.dataset.freedomHandled==='1') return;
    e.preventDefault();
    e.stopImmediatePropagation();
    form.dataset.freedomHandled='1';
    const btn=form.querySelector('button[type="submit"]');
    const oldText=btn?.textContent||'Отправить заявку';
    const success=document.getElementById('successMessage');
    try{
      if(btn){btn.disabled=true;btn.textContent='Сохраняем заявку…';}
      const fd=new FormData(form);
      const booking=await createBooking(fd);
      if(btn) btn.textContent='Отправляем уведомление…';
      const notify=new FormData(form);
      notify.append('type','Новое бронирование FreeDom');
      notify.append('booking_total',String(booking.total)+' ₽');
      notify.append('room_name',booking.room.name);
      notify.append('nights',String(booking.nights));
      const response=await fetch(FORM_ENDPOINT,{method:'POST',body:notify,headers:{Accept:'application/json'}});
      if(!response.ok) console.warn('Formspree notification failed:',response.status);
      form.style.display='none';
      if(success) success.classList.add('show');
    }catch(err){
      console.error('FreeDom booking error:',err);
      alert('Не удалось сохранить бронирование: '+(err?.message||'неизвестная ошибка'));
    }finally{
      if(btn){btn.disabled=false;btn.textContent=oldText;}
      form.dataset.freedomHandled='0';
    }
  }

  // Capture phase guarantees this handler receives the form before any native Formspree submit handler.
  document.addEventListener('submit',handleBookingSubmit,true);
  console.log('FreeDom booking sync loaded');
})();
