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
      return {roomName:document.getElementById('bookingRoomName')?.value||document.getElementById('bookingModalTitle')?.textContent||'',roomType:'',checkin:document.getElementById('bookingCheckIn')?.value||'',checkout:document.getElementById('bookingCheckOut')?.value||'',adults:Number(document.getElementById('bookingGuestCount')?.value||1),children:0,name:document.getElementById('bookingGuestNameModal')?.value?.trim()||'',phone:document.getElementById('bookingGuestPhoneModal')?.value?.trim()||'',email:document.getElementById('bookingGuestEmailModal')?.value?.trim()||'',notes:'',source:'website'};
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

  async function loadEvents(){
    const host=document.getElementById('eventsCarousel');
    if(!host)return;
    const {data,error}=await sb.from('events').select('id,name,description,event_date,start_time,end_time,location,price,image_url,mentor_name,mentor_description,mentor_photo_url').eq('is_active',true).eq('show_on_home',true).gte('event_date',new Date().toISOString().slice(0,10)).order('event_date',{ascending:true}).order('start_time',{ascending:true});
    if(error){console.warn('FreeDom events load error:',error);return;}
    if(!data?.length){host.innerHTML='';const section=host.closest('.fade-section');if(section)section.style.display='none';return;}
    host.innerHTML=data.map(ev=>{const date=new Date(ev.event_date+'T00:00:00').toLocaleDateString('ru-RU',{day:'numeric',month:'long',year:'numeric'});const img=ev.image_url||'images/gong-meditation.jpg';return `<div class="event-card" data-event-id="${esc(ev.id)}"><img src="${esc(img)}" alt="${esc(ev.name)}"><div class="content"><div class="date">📆 ${esc(date)}${ev.start_time?' · '+esc(ev.start_time):''}</div><h3>${esc(ev.name)}</h3><div class="price">${Number(ev.price||0).toLocaleString('ru-RU')} ₽</div><div class="desc">${esc(ev.description||'')}</div><span class="btn-detail">Подробнее →</span></div></div>`}).join('');
    host.querySelectorAll('.event-card').forEach(card=>card.addEventListener('click',()=>openEventModal(data.find(x=>x.id===card.dataset.eventId))));
  }
  function esc(s){return String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))}
  function ensureEventModal(){
    if(document.getElementById('eventRegistrationModal'))return;
    const style=document.createElement('style');style.textContent='.event-mentor{display:flex;gap:12px;align-items:flex-start;background:rgba(255,255,255,.03);padding:12px;border-radius:14px;margin:12px 0}.event-mentor img{width:72px!important;height:72px;object-fit:cover;border-radius:50%;margin:0!important}.event-reg-note{font-size:.8rem;color:#9d96ad;margin-top:6px}.event-error{color:#ff7777;margin:8px 0}.event-reg-success{color:#25D366;text-align:center;padding:14px}';document.head.appendChild(style);
    const m=document.createElement('div');m.id='eventRegistrationModal';m.className='modal-overlay';m.innerHTML='<div class="modal-window"><button class="modal-close" type="button" id="eventModalClose">&times;</button><img id="eventModalImage" src="" alt=""><h2 id="eventModalTitle"></h2><div class="date" id="eventModalDate" style="color:#b8a9d4"></div><div class="price" id="eventModalPrice"></div><div class="description" id="eventModalDesc"></div><div id="eventModalMentor"></div><form id="eventRegistrationForm"><div class="field"><label>Ваше имя *</label><input id="eventGuestName" required placeholder="Иван Петров"></div><div class="field"><label>Телефон *</label><input id="eventGuestPhone" type="tel" required inputmode="tel" autocomplete="tel" placeholder="+7 999 123-45-67"><div class="event-reg-note">Телефон обязателен — он нужен для привязки записи к вашей карточке.</div></div><div class="field"><label>Email</label><input id="eventGuestEmail" type="email" autocomplete="email" placeholder="ivan@mail.ru"></div><div class="field"><label>Количество участников *</label><input id="eventParticipants" type="number" min="1" max="20" value="1" required></div><div class="field"><label>Комментарий</label><textarea id="eventComment" rows="2" placeholder="Пожелания или вопросы"></textarea></div><div id="eventRegError" class="event-error" style="display:none"></div><button type="submit" class="btn btn-block" id="eventRegSubmit">📅 Записаться</button></form><div id="eventRegSuccess" class="event-reg-success" style="display:none">✅ Вы записаны! Мы свяжемся с вами для подтверждения.</div></div>';document.body.appendChild(m);
    document.getElementById('eventModalClose').onclick=()=>closeEventModal();m.addEventListener('click',e=>{if(e.target===m)closeEventModal()});document.getElementById('eventRegistrationForm').addEventListener('submit',submitEventRegistration);
  }
  let selectedEvent=null;
  function openEventModal(ev){if(!ev)return;ensureEventModal();selectedEvent=ev;document.getElementById('eventModalImage').src=ev.image_url||'images/gong-meditation.jpg';document.getElementById('eventModalTitle').textContent=ev.name;const date=new Date(ev.event_date+'T00:00:00').toLocaleDateString('ru-RU',{day:'numeric',month:'long',year:'numeric'});document.getElementById('eventModalDate').textContent='📆 '+date+(ev.start_time?' · '+ev.start_time:'')+(ev.end_time?'–'+ev.end_time:'')+(ev.location?' · '+ev.location:'');document.getElementById('eventModalPrice').textContent=Number(ev.price||0).toLocaleString('ru-RU')+' ₽ / участник';document.getElementById('eventModalDesc').textContent=ev.description||'';const mentor=document.getElementById('eventModalMentor');mentor.innerHTML=ev.mentor_name?`<div class="event-mentor">${ev.mentor_photo_url?`<img src="${esc(ev.mentor_photo_url)}" alt="${esc(ev.mentor_name)}">`:''}<div><b>🧑‍🏫 ${esc(ev.mentor_name)}</b><div style="color:#c8c2d4;margin-top:4px">${esc(ev.mentor_description||'')}</div></div></div>`:'';document.getElementById('eventGuestName').value='';document.getElementById('eventGuestPhone').value='';document.getElementById('eventGuestEmail').value='';document.getElementById('eventParticipants').value='1';document.getElementById('eventComment').value='';document.getElementById('eventRegError').style.display='none';document.getElementById('eventRegSuccess').style.display='none';document.getElementById('eventRegistrationForm').style.display='block';document.getElementById('eventRegSubmit').style.display='block';document.getElementById('eventRegistrationModal').classList.add('active');document.body.style.overflow='hidden'}
  function closeEventModal(){const m=document.getElementById('eventRegistrationModal');if(m)m.classList.remove('active');document.body.style.overflow=''}
  function normalizePhone(v){const d=String(v||'').replace(/\D/g,'');if(/^8\d{10}$/.test(d))return '7'+d.slice(1);if(/^7\d{10}$/.test(d))return d;return d}
  async function submitEventRegistration(e){e.preventDefault();const btn=document.getElementById('eventRegSubmit'),err=document.getElementById('eventRegError'),form=document.getElementById('eventRegistrationForm');err.style.display='none';btn.disabled=true;btn.textContent='Записываем…';const name=document.getElementById('eventGuestName').value.trim(),phone=normalizePhone(document.getElementById('eventGuestPhone').value),email=document.getElementById('eventGuestEmail').value.trim(),participants=Math.max(1,Number(document.getElementById('eventParticipants').value)||1),comment=document.getElementById('eventComment').value.trim();try{if(!name)throw new Error('Укажите имя.');if(!/^7\d{10}$/.test(phone))throw new Error('Введите корректный номер телефона.');const {data,error}=await sb.rpc('create_event_registration',{p_event_id:selectedEvent.id,p_guest_name:name,p_phone:phone,p_email:email||null,p_participants:participants,p_comment:comment||null});if(error)throw error;const total=Number(selectedEvent.price||0)*participants;const fd=new FormData();fd.append('type','📅 Новая запись на событие FreeDom');fd.append('event',selectedEvent.name);fd.append('event_date',selectedEvent.event_date);fd.append('event_time',selectedEvent.start_time||'');fd.append('location',selectedEvent.location||'');fd.append('guest_name',name);fd.append('guest_phone',phone);fd.append('guest_email',email||'не указан');fd.append('participants',String(participants));fd.append('total',String(total)+' ₽');fd.append('registration_id',data.id);try{const n=await fetch(FORM_ENDPOINT,{method:'POST',body:fd,headers:{Accept:'application/json'}});if(!n.ok)console.warn('Event notification failed:',n.status)}catch(ne){console.warn('Event notification error:',ne)}form.style.display='none';btn.style.display='none';document.getElementById('eventRegSuccess').style.display='block';}catch(ex){console.error('Event registration error:',ex);err.textContent='Ошибка: '+(ex.message||'не удалось записаться');err.style.display='block';btn.disabled=false;btn.textContent='📅 Записаться'}}
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',()=>{ensureEventModal();loadEvents()});else{ensureEventModal();loadEvents()}
  console.log('FreeDom booking sync v5 loaded');
})();