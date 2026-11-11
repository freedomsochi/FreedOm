import { defineAgent } from "eve";
import { openai } from "eve/models/openai";

export default defineAgent({
  description: "Designs and implements smooth, performant motion for FreeDom: orbit rotation, drag, inertia, snapping, transitions, card interactions, scroll scenes, and accessible reduced-motion behavior.",
  model: openai("gpt-5.4"),
});