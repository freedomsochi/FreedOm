# FreeDom Agents — setup status

Updated: 2026-11-10

## Runtime and deployment

- Separate Vercel project: `freedom-agents`.
- Project ID: `prj_m4M7FQM0kWhVZPcSMXWdOB11ZN55`.
- Repository: `freedomsochi/FreedOm`.
- Root directory: `agent-runtime`.
- Node.js project setting: `24.x`.
- Active implementation branch: `freedom-github-tools-integration`.
- Latest confirmed READY deployment: `dpl_6yG6YD4AV7P59tWCdUuWU5gHVhCm`.
- Deployment commit: `4cf3fef618729657bfdd9f55b5dd778a3bcf1006` (`Disable recursive root-agent delegation`).
- Preview URL: https://freedom-agents-d1ajrvd4t-sergeyogorodnik19-3325s-projects.vercel.app
- Vercel SSO protection is enabled for deployment URLs.
- Public FreeDom project `freed-om` and its Production deployment have not been changed.

The latest deployment is READY. This confirms build/deployment only, not live runtime or chat functionality.

## Team structure

- Root coordinator: `agent/agent.ts` and `agent/instructions.md`.
- Four declared specialists: `designer`, `programmer`, `motion`, `tester` under `agent/subagents/`.
- Each specialist has its own instructions. Eve subagents do not inherit root instructions or tools; the specialist prompts explicitly constrain their scope and return findings to the coordinator.
- Coordinator is the sole GitHub writer. Specialists provide analysis and recommendations; they do not commit repository changes.
- Root agent sets `tool: false` to avoid recursive delegation to a copy of itself. It is instructed to invoke all four named specialists separately for multi-page/process tasks.

## GitHub integration

- Owner-created Vercel connector label: `github/freedom-agents-github`.
- Connector ID recorded from setup: `scl_vUPTXpsk35EE0gjjFe3THw`.
- GitHub extension file: `agent/extensions/github.ts`.
- Extension package: `@github-tools/eve-extension@0.10.0`.
- Current preset: `maintainer`; unsupported Gist tools are excluded because Connect installation tokens do not support Gist operations.
- Extension compiles in the READY build.
- Extension write tools retain the package's default approval behavior.
- Connector-to-project lookup for this project currently returns 404; listing connectors returns 403. The owner previously reported completing the UI setup, but the available API does not confirm the attachment. Do not treat GitHub access as verified. Do not request or store a personal access token.

## What is not yet verified

1. Dedicated authenticated Web Chat. The default Eve HTTP channel exists, but a user-facing Web Chat has not been installed and tested. The documented interactive setup is `npx eve link` followed by `npx eve add channel/web`, then hosting-layout selection and Sign in with Vercel.
2. Live authenticated chat session with the root coordinator.
3. Actual GitHub repository read/write access through the attached connector.
4. Actual invocation and successful completion of all four specialist subagents in a live session.
5. Agent Runs observability. The Vercel Agent Runs API currently returns 403 to this integration.
6. Browser/device testing of any site changes.
7. Runtime configuration and model access under an authenticated user session.

## Next steps

1. Complete the interactive Web Chat installer and Sign in with Vercel for this project.
2. Confirm the GitHub connector is attached to this exact project in Vercel.
3. Start an authenticated session and perform a harmless read-only repository test.
4. Give the coordinator a harmless multi-area brief; verify calls to designer, programmer, motion, and tester, and confirm the tester independently reviews the resulting plan.
5. Only then test a small reversible branch change with the GitHub approval gate.

## Safety boundary

- Never write to `main`, merge a Pull Request, or deploy the public FreeDom Production site.
- Do not perform Supabase schema/data/grant/RLS changes, payment or booking mutations, or destructive operations without explicit owner approval.
- No secrets or personal tokens in source code.
- Do not claim the team is autonomous until authenticated runtime, connector access, delegation, and approval behavior have all been exercised successfully.
- Build success is not runtime verification.
