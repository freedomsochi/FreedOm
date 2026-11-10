# FreeDom Agents — setup status

Updated: 2026-11-09

## Created

- Git branch: `freedom-agents-foundation`.
- Separate Vercel project: `freedom-agents`.
- Vercel project ID: `prj_m4M7FQM0kWhVZPcSMXWdOB11ZN55`.
- Project source: `freedomsochi/FreedOm`, root directory `agent-runtime`.
- Eve runtime scaffold under `agent-runtime/`.
- Root coordinator plus four declared specialists: designer, programmer, motion, tester.
- Initial deployment ID: `dpl_EdWvVpi3uNC2VVs4C1iNhT9rmtvy`.
- Deployment alias: `https://freedom-agents.vercel.app`.
- Vercel build state: `READY`.
- Vercel deployment is in the separate agent project, not the FreeDom public website project. The project currently has SSO deployment protection; direct browser verification was not possible from this session.

## Current limitations — do not claim full autonomy yet

1. Eve build completed, but the agent has not yet been exercised through a live authenticated session. No subagent delegation has been verified.
2. GitHub and Vercel Connect connector listing/management currently returns 403 from the available Vercel connection. No connector UID has been confirmed and no GitHub write integration is configured for the Eve runtime.
3. Until a least-privilege GitHub connector is attached to the `freedom-agents` project, the agent must not claim it can read/write repository files autonomously.
4. Vercel deployment metadata is readable for this project, but connector list operations are denied. Deployment promotion / Production access must remain approval-gated.
5. Model build succeeded, but runtime model invocation has not yet been verified.
6. Current deployment was created on the `freedom-agents-foundation` branch and has READY state. It does not alter the public FreeDom site's Vercel project or its Production deployment.

## Next steps

1. In Vercel team settings, create/authorize a GitHub connector with access only to `freedomsochi/FreedOm`; attach it to the `freedom-agents` project and the required non-production environment.
2. Verify the project root directory is `agent-runtime` and Node runtime is pinned to 24.x.
3. Ensure AI Gateway is enabled for the project; perform a harmless test session.
4. Add a narrowly scoped GitHub MCP connection/tooling layer to Eve using the confirmed connector UID. Do not invent the UID or hardcode a PAT.
5. Add a web channel protected by authenticated user access. Do not expose an anonymous write-capable session endpoint.
6. Verify that the coordinator invokes each specialist and returns structured task receipts.
7. Only then enable routine branch writes. Keep main/Production, Supabase schema/data changes, financial actions, and destructive operations behind owner approval.


## GitHub tools integration — in progress

- Connector created by owner: `github/freedom-agents-github` (connector ID `scl_vUPTXpsk35EE0gjjFe3THw`).
- Integration branch: `freedom-github-tools-integration`.
- Added `@github-tools/eve-extension` and `@vercel/connect` dependencies (currently tagged `latest`; lockfile/pinning still required).
- Added `agent/extensions/github.ts` using the `pr-author` preset and explicit approval gates for branch, file, and Pull Request writes.
- Coordinator is designated as sole GitHub writer; specialists return plans/results to coordinator.
- Not yet verified: Vercel project-to-connector link via API (Vercel API returned 403), dependency installation/build, live GitHub token issuance, tool invocation, durable approval, subagent delegation, authenticated user-facing channel.
- Do not claim autonomy until the above runtime checks pass. Do not merge this branch or deploy public Production.
