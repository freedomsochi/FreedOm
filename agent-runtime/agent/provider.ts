import { createOpenAI } from "@ai-sdk/openai";

const apiKey = process.env.YANDEX_API_KEY ?? "";
const folderId = process.env.YANDEX_FOLDER_ID ?? "";
const modelUri =
  process.env.YANDEX_MODEL_URI ??
  `gpt://${folderId}/yandexgpt-5.1`;

// Yandex AI Studio exposes an OpenAI-compatible Chat Completions API.
// Custom headers are merged after the provider's default Bearer header,
// so this explicitly sends Yandex's required "Api-Key" authorization scheme.
const yandex = createOpenAI({
  name: "yandex-ai-studio",
  baseURL: "https://ai.api.cloud.yandex.net/v1",
  apiKey: apiKey || "missing-yandex-api-key",
  headers: {
    Authorization: apiKey ? `Api-Key ${apiKey}` : "Api-Key MISSING_YANDEX_API_KEY",
  },
});

// Use .chat() explicitly: Yandex's compatible endpoint is /v1/chat/completions.
export const yandexModel = yandex.chat(modelUri);
