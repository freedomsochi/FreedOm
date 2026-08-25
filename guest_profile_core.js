// FreeDom CRM — guest profile core module
// Phase 1: shared helpers and safe bootstrap. Existing v13 remains the production source until the module is fully migrated.
(function(){
  const esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  const money=n=>(Number(n)||0).toLocaleString('ru-RU')+' ₽';
  const date=d=>d?new Date(d+'T00:00:00').toLocaleDateString('ru-RU'):'—';
  window.FreeDomGuestProfileCore={esc,money,date};
})();
