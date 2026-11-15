const apiKey = process.env.YANDEX_API_KEY;
const folderId = process.env.YANDEX_FOLDER_ID;
const modelUri =
  process.env.YANDEX_MODEL_URI ??
  (folderId ? `gpt://${folderId}/yandexgpt-5.1` : "");

if (!apiKey || !folderId || !modelUri) {
  console.error(
    "Missing YANDEX_API_KEY, YANDEX_FOLDER_ID, or YANDEX_MODEL_URI. " +
      "Set them in your local environment; never paste the API key into chat.",
  );
  process.exit(1);
}

const endpoint = "https://ai.api.cloud.yandex.net/v1/chat/completions";

try {
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      Authorization: `Api-Key ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: modelUri,
      messages: [
        {
          role: "user",
          content: "Reply with exactly this text and nothing else: YANDEX_PROVIDER_OK",
        },
      ],
      max_tokens: 32,
      temperature: 0,
    }),
    signal: AbortSignal.timeout(30_000),
  });

  const payload = await response.json().catch(() => null);

  if (!response.ok) {
    const message =
      payload?.error?.message ??
      payload?.message ??
      `HTTP ${response.status} ${response.statusText}`;
    console.error(`Yandex AI Studio request failed: ${message}`);
    console.error("Check API-key scope, service-account role, folder ID, and model URI.");
    process.exit(1);
  }

  const answer = payload?.choices?.[0]?.message?.content;
  if (typeof answer !== "string" || answer.length === 0) {
    console.error("Yandex responded, but the expected Chat Completions text was missing.");
    console.error(JSON.stringify(payload));
    process.exit(1);
  }

  console.log("Yandex AI Studio connection: OK");
  console.log(`Model: ${modelUri}`);
  console.log(`Response: ${answer}`);
  if (payload.usage) {
    console.log(`Tokens: ${JSON.stringify(payload.usage)}`);
  }
} catch (error) {
  console.error(
    `Could not reach Yandex AI Studio: ${error instanceof Error ? error.message : String(error)}`,
  );
  process.exit(1);
}
