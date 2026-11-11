import { defineAgent } from "eve";
import { openai } from "eve/models/openai";

export default defineAgent({
  model: openai("gpt-5.4"),
  // The coordinator delegates to the four declared specialists, not to a recursive copy of itself.
  tool: false,
});