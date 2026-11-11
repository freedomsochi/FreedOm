import { defineAgent } from "eve";
import { openai } from "eve/models/openai";

export default defineAgent({
  description: "Performs functional, responsive, accessibility, security, and regression testing for FreeDom pages, Supabase flows, booking, events, kitchen orders, and CRM.",
  model: openai("gpt-5.4"),
});