import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ ok: false, error: "POST required" }), {
      status: 405,
      headers: { ...corsHeaders, Allow: "POST, OPTIONS" },
    });
  }

  // verify_jwt=true validates that the caller supplied a valid Supabase JWT.
  // This exact comparison adds the missing service-to-service authorization:
  // a normal authenticated user's JWT must not be allowed to send Telegram messages.
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const authorization = req.headers.get("Authorization");

  if (!serviceRoleKey || authorization !== `Bearer ${serviceRoleKey}`) {
    return new Response(JSON.stringify({ ok: false, error: "Forbidden" }), {
      status: 403,
      headers: corsHeaders,
    });
  }

  try {
    const body = await req.json();
    const token = Deno.env.get("TELEGRAM_BOT_TOKEN");
    const chatId = Deno.env.get("TELEGRAM_CHAT_ID");

    if (!token || !chatId) {
      return new Response(JSON.stringify({ ok: false, error: "Telegram secrets are not configured" }), {
        status: 500,
        headers: corsHeaders,
      });
    }

    const type = body.type === "kitchen" ? "kitchen" : body.type === "vegray" ? "vegray" : "booking";
    const esc = (value: unknown) =>
      String(value ?? "—").replace(/[&<>]/g, (char) => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
      })[char]!);

    let message = "";
    if (type === "kitchen") {
      message = `🍲 <b>Новый заказ кухни</b>\\n\\n👤 Гость: ${esc(body.guest_name)}\\n📞 Телефон: ${esc(body.phone)}\\n📋 Заказ: ${esc(body.order_summary)}\\n💰 Сумма: ${esc(body.total_amount)}\\n🆔 Заказ: ${esc(body.order_id)}`;
    } else if (type === "vegray") {
      message = `🥗 <b>Новый заказ Veg Raw</b>\\n\\n👤 Клиент: ${esc(body.customer_name)}\\n📞 Телефон: ${esc(body.phone)}\\n💰 Сумма: ${esc(body.total_amount)}\\n📋 Заказ: ${esc(body.order_summary)}\\n🆔 Заказ: ${esc(body.order_id)}`;
    } else {
      message = `🏠 <b>Новое бронирование</b>\\n\\n👤 Гость: ${esc(body.guest_name)}\\n📞 Телефон: ${esc(body.phone)}\\n📧 Email: ${esc(body.email)}\\n🏨 Номер: ${esc(body.room)}\\n📅 ${esc(body.check_in)} → ${esc(body.check_out)}\\n💰 Сумма: ${esc(body.total_amount)}\\n🆔 Бронь: ${esc(body.booking_id)}`;
    }

    const telegramResponse = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ chat_id: chatId, text: message, parse_mode: "HTML" }),
    });
    const result = await telegramResponse.json();

    if (!telegramResponse.ok || !result.ok) {
      return new Response(JSON.stringify({ ok: false, error: result.description ?? "Telegram error" }), {
        status: 502,
        headers: corsHeaders,
      });
    }

    return new Response(JSON.stringify({ ok: true, message_id: result.result?.message_id }), {
      headers: corsHeaders,
    });
  } catch {
    return new Response(JSON.stringify({ ok: false, error: "Invalid request or notification failure" }), {
      status: 400,
      headers: corsHeaders,
    });
  }
});
