import { createOpenAI } from "@ai-sdk/openai";

const apiKey = process.env.YANDEX_API_KEY ?? "";
const folderId = process.env.YANDEX_FOLDER_ID ?? "";
const modelUri =
  process.env.YANDEX_MODEL_URI ??
  `gpt://${folderId}/yandexgpt-5.1`;

// Yandex AI Studio exposes an OpenAI-compatible Chat Completions API.
// The provider's custom Authorization header overrides its default Bearer scheme.
const yandex = createOpenAI({
  name: "yandex-ai-studio",
  baseURL: "https://ai.api.cloud.yandex.net/v1",
  apiKey: apiKey || "missing-yandex-api-key",
  project: folderId,
  headers: {
    Authorization: apiKey ? `Api-Key ${apiKey}` : "Api-Key MISSING_YANDEX_API_KEY",
  },
});

// Use .chat() explicitly: Yandex's compatible endpoint is /v1/chat/completions.
export const yandexModel = yandex.chat(modelUri);
