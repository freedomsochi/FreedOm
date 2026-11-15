import { defineAgent } from "eve";
import { yandexModel } from "../../provider";

export default defineAgent({
  description: "Reviews completed FreeDom tasks, agent outputs, defects, owner feedback, and test evidence; identifies repeatable lessons and proposes controlled improvements to team instructions, skills, knowledge, and evals. It never edits application code or changes its own instructions.",
  model: yandexModel,
});