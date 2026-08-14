(function(){
  'use strict';
  const SUPABASE_URL='https://vutmbhsclmcfqqlzxqkc.supabase.co';
  const SUPABASE_KEY='sb_publishable_G7jiYh_r-oC9gkd1a09Ncw_5BKgfV_q';
  const FORM_ENDPOINT='https://formspree.io/f/xpqgkzgo';
  if(!window.supabase){console.error('FreeDom: Supabase library is not loaded');return;}
  const sb=window.supabase.createClient(SUPABASE_URL,SUPABASE_KEY);

  function val(form,name){const el=form.querySelector('[name="'+name+'"]');return el?String(el.value||'').trim():'';}

  async function resolveRoom(roomType,roomName){
    if(roomName){
      const {data,error}=await sb.from('rooms').select('id,name,price_per_night').eq('name',roomName).maybeSingle();
      if(error)throw error;
      if(data)return data;
    }
    const map={family:['Семейная комната'],balcony:['Двухместный с балконом №1','Двухместный с балконом №2'],attic:['Мансардная комната №1','Мансардная комната №2'],bungalow:['Бунгало в саду'],balcony_bed:['Спальное место на балконе'],hostel_standart:['Хостел стандарт'],hostel_economy:['Хостел эконом']};
    const names=map[roomType];
    if(!names)throw new Error('Не определён тип номера.');
    const {data,error}=await sb.from('rooms').select('id,name,price_per_night').in('name',names);
    if(error)throw error;
    if(!data?.length)throw new Error('Выбранный номер не найден в базе.');
    return data[0];
  }

  async function createBookingFromData(d){
    const start=new Date(d.checkin+'T00:00:00'),end=new Date(d.checkout+'T00:00:00');
    const nights=Math.round((end-start)/86400000);
    if(!d.checkin||!d.checkout||!d.name||!d.phone)throw new Error('Заполните имя, телефон и даты.');
    if(!Number.isFinite(nights)||nights<=0)throw new Error('Дата выезда должна быть позже даты заезда.');
    const room=await resolveRoom(d.roomType,d.roomName);
    const ids=d.roomType?null:[room.id];
    let candidates=[room];
    if(d.roomType){
      const map={family:['Семейная комната'],balcony:['Двухместный с балконом №1','Двухместный с балконом №2'],attic:['Мансардная комната №1','Мансардная комната №2'],bungalow:['Бунгало в саду'],balcony_bed:['Спальное место на балконе'],hostel_standart:['Хостел стандарт'],hostel_economy:['Хостел эконом']};
      const {data:r,error:re}=await sb.from('rooms').select('id,name,price_per_night').in('name',map[d.roomType]||[]);if(re)throw re;if(r?.length)candidates=r;
    }
    const candidateIds=candidates.map(r=>r.id);
    const {data:busy,error:be}=await sb.from('bookings').select('room_id,check_in_date,check_out_date,status').in('room_id',candidateIds).lt('check_in_date',d.checkout).gt('check_out_date',d.checkin);
    if(be)throw be;
    const active=new Set(['новое','подтверждено','активна','долг','проживает']);
    const busyIds=new Set((busy||[]).filter(b=>active.has(String(b.status||'').toLowerCase())).map(b=>b.room_id));
    const selected=candidates.find(r=>!busyIds.has(r.id));
    if(!selected)throw new Error('На выбранные даты нет свободного номера этого типа.');
    const total=Math.round(Number(selected.price_per_night||0)*nights);
    const payload={room_id:selected.id,user_id:null,guest_name:d.name,guest_phone:d.phone,guest_email:d.email||null,check_in_date:d.checkin,check_out_date:d.checkout,status:'новое',services:{children:d.children||0,notes:d.notes||'',source:d.source||'',room_type:d.roomType||'',booking_source:'website'},total_amount:total,guest_count:(d.adults||1)+(d.children||0),discount_amount:0,paid_amount:0,payment_status:'не выбрано'};
    const {data,error}=await sb.from('bookings').insert(payload).select('id').single();
    if(error)throw error;
    return {id:data.id,total,nights,room:selected};
  }

  function isBookingForm(form){
    if(!form)return false;
    if(form.id==='bookingForm'||form.id==='bookingModalForm')return true;
    const action=(form.getAttribute('action')||'').toLowerCase();
    return action.includes('formspree.io/f/xpqgkzgo') && !!(form.querySelector('[name="checkin"]')||form.querySelector('#bookingCheckIn')) && !!(form.querySelector('[name="checkout"]')||form.querySelector('#bookingCheckOut'));
  }

  function getData(form){
    if(form.id==='bookingModalForm'){
      return {roomName:document.getElementById('bookingRoomName')?.value||document.getElementById('bookingModalTitle')?.textContent||'',roomType:'',checkin:document.getElementById('bookingCheckIn')?.value||'',checkout:document.getElementById('bookingCheckOut')?.value||'',adults:Number(document.getElementById('bookingGuestCount')?.value||1),children:0,name:document.getElementById('bookingGuestName')?.value?.trim()||'',phone:document.getElementById('bookingGuestPhone')?.value?.trim()||'',email:document.getElementById('bookingGuestEmail')?.value?.trim()||'',notes:'',source:'website'};
    }
    return {roomType:val(form,'room_type'),roomName:'',checkin:val(form,'checkin'),checkout:val(form,'checkout'),adults:Number(val(form,'adults'))||1,children:Number(val(form,'children'))||0,name:val(form,'name'),phone:val(form,'phone'),email:val(form,'email'),notes:val(form,'notes'),source:val(form,'source')};
  }

  async function notify(form,booking){
    const fd=new FormData(form);
    fd.append('type','Новое бронирование FreeDom');
    fd.append('booking_id',booking.id);
    fd.append('booking_total',String(booking.total)+' ₽');
    fd.append('room_name',booking.room.name);
    fd.append('nights',String(booking.nights));
    try{const r=await fetch(form.getAttribute('action')||FORM_ENDPOINT,{method:'POST',body:fd,headers:{Accept:'application/json'}});if(!r.ok)console.warn('Formspree notification failed:',r.status);}catch(e){console.warn('Formspree notification error:',e);}
  }

  document.addEventListener('submit',async function(e){
    const form=e.target;
    if(!isBookingForm(form)||form.dataset.freedomProcessing==='1')return;
    e.preventDefault();e.stopImmediatePropagation();form.dataset.freedomProcessing='1';
    const btn=form.querySelector('button[type="submit"]');const old=btn?.textContent||'Отправить заявку';
    try{
      if(btn){btn.disabled=true;btn.textContent='Сохраняем бронирование…';}
      const booking=await createBookingFromData(getData(form));
      if(btn)btn.textContent='Отправляем уведомление…';
      await notify(form,booking);
      const success=document.getElementById('successMessage');
      const modalSuccess=document.getElementById('bookingModalSuccess');
      if(success)success.classList.add('show');
      if(modalSuccess){form.style.display='none';modalSuccess.style.display='block';}
      console.log('FreeDom booking saved:',booking.id);
    }catch(err){
      console.error('FreeDom booking error:',err);
      const modalError=document.getElementById('bookingModalError');
      if(modalError){modalError.textContent='Ошибка: '+(err?.message||'неизвестная ошибка');modalError.style.display='block';}
      else alert('Не удалось сохранить бронирование: '+(err?.message||'неизвестная ошибка'));
    }finally{
      if(btn){btn.disabled=false;btn.textContent=old;}form.dataset.freedomProcessing='0';
    }
  },true);
  console.log('FreeDom booking sync v4 loaded');
})();