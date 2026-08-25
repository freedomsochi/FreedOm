// FreeDom CRM — shared status helpers for guest profile UI
(function(){
  function num(v){return Number(v)||0;}
  window.FreeDomGuestStatus={
    payment(paid,charged,debt){
      const p=num(paid),c=num(charged),d=num(debt);
      if(d<=0)return{key:'paid',label:'Оплачено',icon:'✓',className:'ok'};
      if(p>0&&c>0)return{key:'partial',label:'Частично оплачено',icon:'◐',className:'partial'};
      return{key:'unpaid',label:'Не оплачено',icon:'!',className:'danger'};
    },
    booking(b){const total=num(b?.total_amount),paid=num(b?.paid_amount);return this.payment(paid,total,Math.max(0,total-paid));},
    order(o){const total=num(o?.total_amount),paid=num(o?.paid_amount);return this.payment(paid,total,Math.max(0,total-paid));},
    chip(s){return `<span class="chip ${s.className}">${s.icon} ${s.label}</span>`;},
    progress(paid,charged,debt){
      const p=Math.max(0,num(paid)),c=Math.max(0,num(charged));
      if(c<=0)return '';
      const pct=Math.max(0,Math.min(100,Math.round((p/c)*100)));
      if(p<=0||p>=c)return '';
      return `<div class="payment-progress"><div class="payment-progress-track"><span style="width:${pct}%"></span></div><div class="payment-progress-caption">${pct}% оплачено</div></div>`;
    }
  };
})();
