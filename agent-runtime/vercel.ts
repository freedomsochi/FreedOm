import { withEve } from "eve/vercel";

export default await withEve(
  {
    services: {
      web: {
        framework: "nextjs",
        root: "apps/web",
        buildCommand: "node ../../node_modules/next/dist/bin/next build",
      },
    },
    routes: [{ src: "^(.*)$", destination: { type: "service", service: "web" } }],
  },
  // Vercel evaluates vercel.ts from the repository root; the Eve project is
  // in the configured project Root Directory.
  { root: "agent-runtime" },
);
