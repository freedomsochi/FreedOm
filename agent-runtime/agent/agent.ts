import { defineAgent } from "eve";
import { yandexModel } from "./provider";

export default defineAgent({
  model: yandexModel,
  // YandexGPT is not in the AI Gateway catalog; declare its supported context size for Eve compaction.
  modelContextWindowTokens: 32_000,
  // The coordinator delegates to the five declared specialists, not to a recursive copy of itself.
  tool: false,
});