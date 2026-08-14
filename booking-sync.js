(function(){
  const SUPABASE_URL='https://vutmbhsclmcfqqlzxqkc.supabase.co';
  const SUPABASE_KEY='sb_publishable_G7jiYh_r-oC9gkd1a09Ncw_5BKgfV_qC';
  if(!window.supabase) return;
  const sb=window.supabase.createClient(SUPABASE_URL,SUPABASE_KEY);
  const roomMap={family:['Семейная комната'],balcony:['Двухместный с балконом №1','Двухместный с балконом №2'],attic:['Мансардная комната №1','Мансардная комната №2'],bungalow:['Бунгало в саду'],balcony_bed:['Спальное место на балконе'],hostel_standart:['Хостел стандарт'],hostel_economy:['Хостел эконом']};

  async function safeUserId(){
    try{
      const {data}=await sb.auth.getSession();
      const id=data?.session?.user?.id||null;
      if(!id) return null;
      const {data:user,error}=await sb.from('users').select('user_id').eq('user_id',id).maybeSingle();
      return error||!user?null:id;
    }catch(_){return null;}
  }

  async function createBooking({roomType,checkin,checkout,adults,children,guestName,phone,email,notes,source}){
    if(!roomMap[roomType]||!checkin||!checkout||!guestName||!phone) throw new Error('Заполните обязательные поля.');
    const start=new Date(checkin+'T00:00:00'),end=new Date(checkout+'T00:00:00');
    const nights=Math.round((end-start)/86400000);
    if(!Number.isFinite(nights)||nights<=0) throw new Error('Дата выезда должна быть позже даты заезда.');
    const {data:rooms,error:roomsError}=await sb.from('rooms').select('id,name,price_per_night').in('name',roomMap[roomType]);
    if(roomsError) throw roomsError;
    if(!rooms?.length) throw new Error('Не найден выбранный тип номера.');
    const ids=rooms.map(r=>r.id);
    const {data:busy,error:busyError}=await sb.from('bookings').select('room_id,check_in_date,check_out_date,status').in('room_id',ids).lt('check_in_date',checkout).gt('check_out_date',checkin);
    if(busyError) throw busyError;
    const active=new Set(['новое','подтверждено','проживает','активна']);
    const busyIds=new Set((busy||[]).filter(b=>active.has(String(b.status||'').toLowerCase())).map(b=>b.room_id));
    const room=rooms.find(r=>!busyIds.has(r.id));
    if(!room) throw new Error('На выбранные даты нет свободного номера этого типа.');
    const total=Math.round(Number(room.price_per_night||0)*nights);
    const userId=await safeUserId();
    const payload={room_id:room.id,user_id:userId,guest_name:guestName,guest_phone:phone,guest_email:email||null,check_in_date:checkin,check_out_date:checkout,status:'новое',services:{children:Number(children)||0,notes:notes||'',source:source||'',room_type:roomType},total_amount:total,guest_count:(Number(adults)||1)+(Number(children)||0),discount_amount:0,paid_amount:0,payment_status:'не выбрано'};
    const {data,error}=await sb.from('bookings').insert(payload).select('id').single();
    if(error) throw error;
    return {id:data.id,total,room};
  }

  const form=document.getElementById('bookingForm');
  if(form){
    form.addEventListener('submit',async function(e){
      if(window.__freedomBookingNativeSubmit) return;
      e.preventDefault();
      const btn=form.querySelector('button[type="submit"]');
      const oldText=btn?.textContent||'Отправить заявку';
      const fd=new FormData(form);
      try{
        if(btn){btn.disabled=true;btn.textContent='Сохраняем заявку…';}
        await createBooking({roomType:String(fd.get('room_type')||''),checkin:String(fd.get('checkin')||''),checkout:String(fd.get('checkout')||''),adults:Number(fd.get('adults')||1),children:Number(fd.get('children')||0),guestName:String(fd.get('name')||'').trim(),phone:String(fd.get('phone')||'').trim(),email:String(fd.get('email')||'').trim(),notes:String(fd.get('notes')||'').trim(),source:String(fd.get('source')||'')});
        window.__freedomBookingNativeSubmit=true;
        if(btn) btn.textContent='Отправляем уведомление…';
        HTMLFormElement.prototype.submit.call(form);
      }catch(err){
        console.error('FreeDom booking sync error:',err);
        alert('Не удалось сохранить бронирование: '+(err?.message||'неизвестная ошибка'));
        if(btn){btn.disabled=false;btn.textContent=oldText;}
      }
    });
  }
})();
