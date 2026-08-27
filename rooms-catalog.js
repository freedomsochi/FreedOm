/* FreeDom — shared room catalog loader.
 * Keeps the public room list driven by Supabase instead of hardcoded room cards.
 * This module is intentionally UI-agnostic so the light and legacy dark versions
 * can use the same source of truth without sharing visual styles.
 */

export async function loadRoomsCatalog(supabase) {
  if (!supabase) throw new Error('Supabase client is required');

  const { data, error } = await supabase.rpc('get_rooms_catalog');
  if (error) throw error;

  return (data || []).map((room) => ({
    id: room.id,
    name: room.name,
    description: room.description || '',
    pricePerNight: Number(room.price_per_night || 0),
    capacity: Number(room.capacity || 0),
    imageUrl: room.image_url || '',
    bookingMode: room.booking_mode || 'whole',
  }));
}

export function roomBookingLabel(room) {
  return room.bookingMode === 'places' ? 'место' : 'комната';
}

export function formatRoomPrice(price) {
  return `${new Intl.NumberFormat('ru-RU').format(price)} ₽ / ночь`;
}
