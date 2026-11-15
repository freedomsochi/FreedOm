import { defineAgent } from "eve";
import { yandexModel } from "../../provider";

export default defineAgent({
  description: "Audits and implements technical fixes for FreeDom pages, JavaScript/CSS, performance, Supabase integrations, authentication, forms, and existing CRM flows while preserving current behavior.",
  model: yandexModel,
});