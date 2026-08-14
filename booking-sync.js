(function(){
  const SUPABASE_URL='https://vutmbhsclmcfqqlzxqkc.supabase.co';
  const SUPABASE_KEY='sb_publishable_G7jiYh_r-oC9gkd1a09Ncw_5BKgfV_qC';
  if(!window.supabase || !document.getElementById('bookingForm')) return;
  const sb=window.supabase.createClient(SUPABASE_URL,SUPABASE_KEY);
  const form=document.getElementById('bookingForm');
  const roomMap={family:['Семейная комната'],balcony:['Двухместный с балконом №1','Двухместный с балконом №2'],attic:['Мансардная комната №1','Мансардная комната №2'],bungalow:['Бунгало в саду'],balcony_bed:['Спальное место на балконе'],hostel_standart:['Хостел стандарт'],hostel_economy:['Хостел эконом']};
  form.addEventListener('submit',async function(e){
    if(window.__freedomBookingNativeSubmit) return;
    e.preventDefault();
    const btn=form.querySelector('button[type="submit"]'); const oldText=btn.textContent; const fd=new FormData(form);
    const roomType=String(fd.get('room_type')||''),checkin=String(fd.get('checkin')||''),checkout=String(fd.get('checkout')||'');
    const adults=Math.max(1,Number(fd.get('adults')||1)),children=Math.max(0,Number(fd.get('children')||0));
    const guestName=String(fd.get('name')||'').trim(),phone=String(fd.get('phone')||'').trim(),email=String(fd.get('email')||'').trim()||null;
    const notes=String(fd.get('notes')||'').trim(),source=String(fd.get('source')||'');
    if(!roomMap[roomType]||!checkin||!checkout||!guestName||!phone){alert('Пожалуйста, заполните обязательные поля.');return;}
    const start=new Date(checkin+'T00:00:00'),end=new Date(checkout+'T00:00:00');
    const nights=Math.round((end-start)/86400000);
    if(!Number.isFinite(nights)||nights<=0){alert('Дата выезда должна быть позже даты заезда.');return;}
    btn.disabled=true;btn.textContent='Сохраняем заявку…';
    try{
      const {data:rooms,error:roomsError}=await sb.from('rooms').select('id,name,price_per_night').in('name',roomMap[roomType]);
      if(roomsError) throw roomsError;
      if(!rooms||!rooms.length) throw new Error('Не найден выбранный тип номера.');
      const ids=rooms.map(r=>r.id);
      const {data:busy,error:busyError}=await sb.from('bookings').select('room_id,check_in_date,check_out_date,status').in('room_id',ids).lt('check_in_date',checkout).gt('check_out_date',checkin);
      if(busyError) throw busyError;
      const activeStatuses=new Set(['новое','подтверждено','проживает']);
      const busyIds=new Set((busy||[]).filter(b=>activeStatuses.has(String(b.status||'').toLowerCase())).map(b=>b.room_id));
      const room=rooms.find(r=>!busyIds.has(r.id));
      if(!room) throw new Error('На выбранные даты нет свободного номера этого типа.');
      const total=Math.round(Number(room.price_per_night||0)*nights);
      let userId=null;try{const session=await sb.auth.getSession();userId=session.data.session?.user?.id||null;}catch(_){ }
      const {error:insertError}=await sb.from('bookings').insert({room_id:room.id,user_id:userId,guest_name:guestName,guest_phone:phone,guest_email:email,check_in_date:checkin,check_out_date:checkout,status:'новое',services:{children,notes,source,room_type:roomType},total_amount:total,guest_count:adults+children,discount_amount:0,paid_amount:0,payment_status:'не выбрано'});
      if(insertError) throw insertError;
      window.__freedomBookingNativeSubmit=true;btn.textContent='Отправляем уведомление…';form.submit();
    }catch(err){console.error('Ошибка сохранения бронирования:',err);alert('Не удалось сохранить бронирование: '+(err.message||'неизвестная ошибка'));btn.disabled=false;btn.textContent=oldText;}
  });
})();
