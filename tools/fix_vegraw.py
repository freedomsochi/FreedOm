from pathlib import Path
import re

path = Path('index.html')
text = path.read_text(encoding='utf-8')

pattern = re.compile(r"    document\.getElementById\('orderForm'\)\.addEventListener\('submit',async function\(e\)\{.*?\n    window\.addEventListener\('load'", re.S)

replacement = """    document.getElementById('orderForm').addEventListener('submit',async function(e){
        e.preventDefault();
        const form=this;
        const submitBtn=form.querySelector('button[type=\"submit\"]');
        const errorDiv=document.getElementById('orderError');
        const successDiv=document.getElementById('orderSuccess');
        errorDiv.style.display='none';
        successDiv.style.display='none';
        submitBtn.disabled=true;
        submitBtn.textContent='Отправка...';

        const name=document.getElementById('orderName').value.trim();
        const price=parseInt(document.getElementById('orderPrice').value)||0;
        const guestName=document.getElementById('orderGuestName').value.trim();
        const guestPhone=document.getElementById('orderGuestPhone').value.trim();
        const guestEmail=document.getElementById('orderGuestEmail').value.trim();
        const quantity=parseInt(document.getElementById('orderQuantity').value)||1;
        const comment=document.getElementById('orderComment').value.trim();

        if(!guestName||!guestPhone){
            errorDiv.textContent='Заполните имя и телефон.';
            errorDiv.style.display='block';
            submitBtn.disabled=false;
            submitBtn.textContent='✅ Заказать';
            return;
        }

        const totalAmount=price*quantity;
        const items=[{name,quantity,price,comment}];

        try{
            const session=await supabase.auth.getSession();
            const userId=session.data.session?.user?.id||null;
            const {error:orderError}=await supabase.from('orders').insert({
                user_id:userId,
                guest_name:guestName,
                guest_phone:guestPhone,
                guest_email:guestEmail||null,
                items,
                total_amount:totalAmount,
                status:'новый',
                payment_status:'не выбрано'
            });
            if(orderError) throw orderError;

            const formData=new FormData();
            formData.append('type','Новый заказ Veg-raw кухни');
            formData.append('item',name);
            formData.append('quantity',String(quantity));
            formData.append('total',String(totalAmount)+' ₽');
            formData.append('guest_name',guestName);
            formData.append('guest_phone',guestPhone);
            formData.append('guest_email',guestEmail||'не указан');
            formData.append('comment',comment||'нет');

            const response=await fetch('https://formspree.io/f/xpqgqkzgo',{
                method:'POST',
                body:formData,
                headers:{Accept:'application/json'}
            });

            if(!response.ok){
                const details=await response.text().catch(()=> '');
                console.warn('Formspree ответил ошибкой:',response.status,details);
            }

            form.style.display='none';
            successDiv.innerHTML='✅ Заказ принят!<br><span style=\"font-size:.9rem;opacity:.7\">Мы получили ваш заказ и скоро свяжемся с вами.</span>';
            successDiv.style.display='block';

            setTimeout(()=>{
                document.getElementById('orderModal').classList.remove('active');
                document.body.style.overflow='';
                form.style.display='block';
                successDiv.style.display='none';
                submitBtn.disabled=false;
                submitBtn.textContent='✅ Заказать';
            },4000);
        }catch(error){
            console.error('Ошибка заказа:',error);
            errorDiv.textContent='Ошибка: '+error.message;
            errorDiv.style.display='block';
            submitBtn.disabled=false;
            submitBtn.textContent='✅ Заказать';
        }
    });
    window.addEventListener('load'"""

if not pattern.search(text):
    raise SystemExit('orderForm handler not found; refusing to modify index.html')

new_text = pattern.sub(replacement, text, count=1)
path.write_text(new_text, encoding='utf-8')
