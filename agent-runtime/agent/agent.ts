import { defineAgent } from "eve";
import { yandexModel } from "./provider";

export default defineAgent({
  model: yandexModel,
  // The coordinator delegates to the five declared specialists, not to a recursive copy of itself.
  tool: false,
});