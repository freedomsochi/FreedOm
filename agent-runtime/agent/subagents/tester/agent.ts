import { defineAgent } from "eve";
import { yandexModel } from "../../provider";

export default defineAgent({
  description: "Performs functional, responsive, accessibility, security, and regression testing for FreeDom pages, Supabase flows, booking, events, kitchen orders, and CRM.",
  model: yandexModel,
});