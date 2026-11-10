# FreeDom Agents — setup status

Updated: 2026-11-10

## Runtime and deployment

- Separate Vercel project: `freedom-agents`.
- Project ID: `prj_m4M7FQM0kWhVZPcSMXWdOB11ZN55`.
- Repository: `freedomsochi/FreedOm`.
- Root directory: `agent-runtime`.
- Node.js project setting: `24.x`.
- Active implementation branch: `freedom-github-tools-integration`.
- Latest confirmed READY deployment before the Node pin change: `dpl_4mTtTCRDqjTQ2vfiEoLegDnHqUYU`, commit `410c95389ba089922b094cda824c5123c251ddd9`.
- That build completed with Eve and the GitHub extension included.
- Build log warned that `engines.node >=24` selected Node 26 despite the Vercel project setting. The package engine has now been pinned to `24.x`; a new deployment is expected and must be checked before treating this change as verified.
- Vercel project has SSO protection enabled for all deployment URLs except custom domains.
- Public FreeDom project `freed-om` and its Production deployment have not been changed.

## Team structure

- Root coordinator: `agent/instructions.md` and `agent/agent.ts`.
- Four declared specialists: `designer`, `programmer`, `motion`, `tester` under `agent/subagents/`.
- Each specialist has its own instructions. Eve subagents do not inherit root instructions or tools; the specialist prompts explicitly constrain their scope and return findings to the coordinator.
- Coordinator is the sole GitHub writer. Specialists must not make repository writes or commits.

## GitHub integration

- Owner-created Vercel connector label: `github/freedom-agents-github`.
- Connector ID recorded from setup: `scl_vUPTXpsk35EE0gjjFe3THw`.
- GitHub extension file: `agent/extensions/github.ts`.
- Extension package: `@github-tools/eve-extension@0.10.0`.
- Current preset: `maintainer`; unsupported Gist tools are excluded because Connect installation tokens do not support Gist operations.
- Extension's write tools retain the package's default approval behavior.
- The extension compiled in the READY build.
- The Vercel connector-to-project lookup currently returns 404 for the recorded connector/project pair. Do not treat the project connection as verified until Vercel confirms it. Do not request or store a personal access token.

## What is not yet verified

- Build-time discovery of the four subagents follows Eve's documented filesystem convention, and each has its own instructions. Live delegation is still unverified.
- The coordinator prompt explicitly names the four subagent tools and requires all four reviews for multi-page/process tasks.

1. Live authenticated chat session with the root coordinator.
2. Actual tool invocation against the connected GitHub repository.
3. Actual delegation to all four specialist subagents in a live session.
4. Agent Runs observability. The Vercel Agent Runs API currently returns 403 to this integration.
5. Browser/device testing of any site changes.
6. Connector attachment in the Vercel project. The owner previously reported completing the UI setup, but the available API lookup does not confirm it.
7. A dedicated Web Chat channel/UI. The default Eve HTTP channel exists, but a user-facing web chat setup has not been completed and tested. The documented setup requires the interactive `npx eve add channel/web` installer and Sign in with Vercel; this has not been run.

## Safety boundary

- Never write to `main`, merge a Pull Request, or deploy the public FreeDom Production site.
- Do not perform Supabase schema/data/grant/RLS changes, payment or booking mutations, or destructive operations without explicit owner approval.
- No secrets or personal tokens in source code.
- Do not claim the team is autonomous until authenticated runtime, connector access, delegation, and approval behavior have all been exercised successfully.
- Build success is not runtime verification.
