# FreeDom Agents

Separate Eve runtime for the FreeDom project team. This directory is intended to become its own Vercel project with Root Directory `agent-runtime`; it must not be deployed through the public website project.

## Team

- Coordinator (root agent): accepts one large brief, reads project context, delegates work, sequences edits, reconciles results, and reports.
- Designer: current visual language, page composition, responsive design, photography briefs and media reuse.
- Technical programmer: HTML/CSS/JS, integrations, performance, Supabase and authentication.
- Motion designer: Orbit, drag/inertia/snap, transitions, micro-interactions and reduced-motion behavior.
- Tester: functional, responsive, accessibility, security and regression checks.

The four specialists are declared Eve subagents. The root agent coordinates them and owns the final plan.

## Local setup

Requires Node.js 24+.

```bash
npm install
npm run dev
```

Before first use, read the Eve docs bundled in `node_modules/eve/docs/README.md` and follow the current Getting Started / Subagents / Connections / Authentication guides. The exact Eve API is versioned with the installed package.

## Required external setup before autonomous code changes

1. Create a separate Vercel project named `freedom-agents` from this repository, with Root Directory `agent-runtime`. Do not connect it to the public site's production project.
2. Attach a GitHub connector to the agent project for repository read/write operations. Use a least-privilege GitHub App installation limited to `freedomsochi/FreedOm`.
3. Configure Vercel AI Gateway/model access.
4. Configure the Eve sandbox and a separate working branch. The agent must never write directly to `main` or publish Production.
5. Add project-scoped access to Vercel Preview metadata only. Deployment promotion and production changes remain approval-gated.
6. Add an authenticated web channel. Do not expose an unauthenticated public session endpoint.
7. Verify delegation and tool permissions with a harmless read-only test before allowing branch writes.

The current ChatGPT Vercel connector could not list Connect connectors/deployments (403). Therefore connector UIDs, Vercel project creation and deployment are intentionally not guessed or hardcoded here.

## Safety policy

- No credentials, admin passwords, service-role keys, provider tokens, or private keys in this repository.
- No production writes, deployment promotion, data deletion, irreversible Supabase changes, or payment/booking mutations without explicit owner approval.
- Routine reversible edits are allowed only on the designated agent working branch.
- Before touching Supabase, inspect schema, RPC definitions, grants, RLS, Edge Functions and call sites. Never mass-revoke grants.
- Agents must distinguish code/static checks from real browser/device testing.
- Project-history copy is owner-authored. Agents prepare layout and media slots only.
