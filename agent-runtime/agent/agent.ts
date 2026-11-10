import { defineAgent } from "eve";

export default defineAgent({
  model: "openai/gpt-5.4",
  // The coordinator delegates to the four declared specialists, not to a recursive copy of itself.
  tool: false,
});
