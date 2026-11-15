# FreeDom Agents — setup status

Updated: 2026-11-15

## Runtime and deployment

- Separate Vercel project: `freedom-agents`.
- Project ID: `prj_m4M7FQM0kWhVZPcSMXWdOB11ZN55`.
- Repository: `freedomsochi/FreedOm`.
- Root directory: `agent-runtime`.
- Node.js project setting: `24.x`.
- Active audit/integration branch: `freedom-autonomy-v2-2026-11-15`.
- Provider code commit during this audit: `f0f7d2425ce104f9709a96011b55f451f48bc595`; subsequent commits update audit documentation and GitHub tool permissions.
- Preview deployment for the latest branch commit is not confirmed. A previous deployment creation attempt was rejected with Vercel `402 payment_required` because the daily deployment limit had been reached.
- Older READY deployment records refer to earlier commits and do not validate the current Yandex provider or six-agent configuration.
- Vercel SSO / Deployment Protection must remain enabled for deployment URLs.
- GitHub API reported `protected: false` for `main` during this audit. Branch protection is not confirmed; the owner should enable PR-required protection and prevent force-push/deletion before relying on GitHub to enforce the no-main-write rule.
- Public FreeDom project `freed-om` and its Production deployment have not been changed.

## Team structure and capability isolation

- Root coordinator: `agent/agent.ts` and `agent/instructions.md`.
- Five declared specialists: `designer`, `programmer`, `motion`, `tester`, `mentor`.
- Every specialist has its own `agent.ts` and role instructions.
- Eve declared subagents do not inherit the root agent's authored extensions/tools; each required specialist therefore has its own capability configuration.
- Root coordinator mounts GitHub `repo-explorer` (read-only).
- Designer, Motion and Tester each mount their own GitHub `repo-explorer` extension (read-only).
- Programmer mounts GitHub `repo-explorer` + `pr-author` through the configured connector. Merge PR, branch deletion and PR/review-thread mutation tools are excluded. Remaining write operations retain the extension's default approval gates.
- Mentor has no GitHub extension and is instructed to propose, not directly apply, changes to code or team knowledge.
- The filesystem configuration is present. Actual connector authentication, tool visibility and write approval behavior have not yet been verified in a live Eve session.

## Yandex AI Studio

- All six agents use the shared `agent/provider.ts` adapter and `YANDEX_MODEL_URI`.
- Base URL: `https://ai.api.cloud.yandex.net/v1`.
- Authorization: `Authorization: Api-Key ...`.
- Folder ID is passed using `OpenAI-Project`.
- Chat Completions is selected explicitly with `.chat(modelUri)`.
- Vercel environment variables are configured for Preview only: `YANDEX_API_KEY`, `YANDEX_FOLDER_ID`, `YANDEX_MODEL_URI`.
- The owner confirmed the service account has `ai.languageModels.user`.
- The owner's screenshot shows `yc.ai.languageModels.execute` among the API key scopes.
- Yandex's current basic Chat Completions guide also documents `yc.ai.foundationModels.execute` for its request example, while the AI Studio key-creation guide says AI Studio-created keys receive `yc.ai.languageModels.execute` for Model Gallery text generation. Treat this documentation difference as an item to resolve with the first real API request; do not rotate or broaden the key preemptively.
- `npm run test:provider` sends a minimal direct Chat Completions request. It checks the credentials, model URI, response shape and folder header; it does not test Eve or the AI SDK adapter itself.
- Provider smoke test has not yet been run with the owner's secret key. Never ask the owner to paste the key into chat.

## Code-level audit — 2026-11-15

- All five specialist `agent.ts` files use the shared Yandex model and declare `modelContextWindowTokens: 32_000`.
- Root coordinator sets `tool: false` to prevent recursive root-agent delegation; its declared specialists remain separate tools.
- Role-specific instructions define the designer, programmer, motion, tester and mentor boundaries.
- Programmer is designated as the only repository writer; designer, motion and tester are read-only; mentor has no GitHub write access.
- Provider adapter now includes the `OpenAI-Project` folder header via the SDK `project` option.
- Direct provider smoke test includes the same `OpenAI-Project` header.
- No current-branch build or live agent run has verified the complete integration after the Yandex provider changes.

## What is not yet verified

1. Eve build and Next.js build for the latest branch commit.
2. Actual Yandex API response using the Preview secret values.
3. Runtime streaming and function calling through the AI SDK/Eve adapter.
4. Authenticated Web Chat session with the root coordinator.
5. Actual GitHub repository read/write access through the configured connector.
6. Live invocation and successful completion of all five specialists.
7. Programmer write approval behavior and inability of read-only agents to write.
8. Agent Runs observability.
9. Browser/device testing of any site changes.

## Next steps

1. When Vercel's deployment quota permits, deploy only this branch to the separate `freedom-agents` Preview project.
2. Run the provider smoke test without exposing the secret key.
3. Check Eve diagnostics and verify all five specialists are registered.
4. Test a harmless coordinator delegation to each read-only specialist.
5. Test a harmless programmer write only after confirming the approval prompt and target branch.
6. Verify the full workflow and report actual PASS / FAIL / NOT TESTED results.

## Safety boundary

- Never write to `main`, merge a Pull Request, or deploy the public FreeDom Production site.
- Do not perform Supabase schema/data/grant/RLS changes, payment or booking mutations, or destructive operations without explicit owner approval.
- No secrets or personal tokens in source code, logs, commits or chat.
- Do not claim the team is autonomous until authenticated runtime, provider calls, connector access, delegation and approval behavior have all been exercised successfully.
- Build success is not runtime verification.
