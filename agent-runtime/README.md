# FreeDom Agents

Separate Eve runtime for the FreeDom project team. This project is isolated from the public FreeDom website.

## Team

- Coordinator (root agent): accepts one large brief, delegates reviews, sequences implementation, reconciles results, and reports.
- Designer: visual language, page composition, responsive design, photography briefs and media reuse.
- Technical programmer: HTML/CSS/JS, integrations, performance, Supabase and authentication.
- Motion designer: Orbit, drag/inertia/snap, transitions, micro-interactions and reduced-motion behavior.
- Tester: functional, responsive, accessibility, security and regression checks.

The four specialists are declared Eve subagents under `agent/subagents/`. The root coordinator is the sole GitHub writer. Specialists return analysis and recommendations; they do not commit repository changes.

## Current deployment

- Vercel project: `freedom-agents`.
- Root Directory: `agent-runtime`.
- Runtime: Node.js 24.x.
- Working branch: `freedom-github-tools-integration`.
- Latest confirmed READY deployment: commit `4cf3fef618729657bfdd9f55b5dd778a3bcf1006`.
- Preview URL: https://freedom-agents-d1ajrvd4t-sergeyogorodnik19-3325s-projects.vercel.app
- Vercel SSO protection is enabled for deployment URLs.
- Public FreeDom project `freed-om` and its Production deployment have not been changed.

Build success confirms compilation/deployment only. It does not prove that authenticated chat, GitHub access, or live subagent delegation works.

## Local setup

Requires Node.js 24.x.

```bash
npm install
npm run dev
```

Before changing Eve APIs, consult the docs bundled in `node_modules/eve/docs/README.md` and follow the version-matched Getting Started, Subagents, Connections, Authentication, and Web Chat guides.

## Remaining setup and verification

1. Complete the dedicated authenticated Web Chat setup from this project directory:
   ```bash
   npx eve link
   npx eve add channel/web
   ``
   Choose the hosting layout and complete the Sign in with Vercel flow. This is interactive and has not yet been run for this project.
2. Verify that the GitHub connector is attached to this exact Vercel project. The owner reported completing the UI step, but the available connector API lookup currently returns 404 and listing connectors returns 403. Do not treat the attachment as verified until confirmed in Vercel.
3. Verify model access and runtime configuration.
4. Run a harmless authenticated read-only test against the repository.
5. Test live delegation to all four specialists, then have the tester independently inspect the result.
6. Only after those checks, enable routine branch changes behind the GitHub extension's approval gate.

The Web Chat installer and browser Sign in with Vercel flow are required. Do not replace them with an unauthenticated public endpoint or a hand-rolled bypass.

## Safety policy

- Never write to `main`, merge a Pull Request, or publish the public FreeDom Production site.
- Routine reversible edits are limited to the designated agent working branch and require the configured GitHub approval gate.
- No credentials, admin passwords, service-role keys, provider tokens, or private keys in this repository.
- No production writes, deployment promotion, data deletion, irreversible Supabase changes, or payment/booking mutations without explicit owner approval.
- Before touching Supabase, inspect schema, RPC definitions, grants, RLS, Edge Functions and call sites. Never mass-revoke grants.
- Agents must distinguish code/static checks from real browser/device testing.
- Project-history copy is owner-authored. Agents prepare layout and media slots only.
