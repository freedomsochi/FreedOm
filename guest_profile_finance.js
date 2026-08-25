// FreeDom CRM — reusable finance helpers for guest profiles
(function(){
  window.FreeDomGuestFinance = {
    status(paid, charged, debt){
      const p=Number(paid)||0, c=Number(charged)||0, d=Number(debt)||0;
      if(d<=0) return {key:'paid',label:'Оплачено',icon:'✓',className:'ok'};
      if(p>0 && c>0) return {key:'partial',label:'Частично оплачено',icon:'◐',className:'partial'};
      return {key:'unpaid',label:'Не оплачено',icon:'!',className:'danger'};
    },
    money(n){ return (Number(n)||0).toLocaleString('ru-RU')+' ₽'; },
    amountFromBreakdown(items, type){
      return (items||[]).filter(x=>x.charge_type===type).reduce((sum,x)=>sum+(Number(x.debt)||0),0);
    }
  };
})();
