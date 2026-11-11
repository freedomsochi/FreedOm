import { defineAgent } from "eve";
import { openai } from "eve/models/openai";

export default defineAgent({
  description: "Audits and improves the existing FreeDom visual design across pages, preserving the approved nature-first visual direction; creates photography briefs, responsive layout specs, and image reuse maps.",
  model: openai("gpt-5.4"),
});