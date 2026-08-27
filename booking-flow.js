/* FreeDom — technical booking bridge for the light homepage. UI intentionally left to the design phase. */
window.FREEDOM_BOOKING = (() => {
  const endpoint = '/api/availability';

  async function availability(checkIn, checkOut) {
    if (!checkIn || !checkOut || checkOut <= checkIn) {
      throw new Error('Выберите корректные даты');
    }
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ check_in: checkIn, check_out: checkOut })
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok || data?.ok === false) {
      throw new Error(data?.error || 'Не удалось получить доступность');
    }
    return data;
  }

  return { availability };
})();
