import githubExtension from "@github-tools/eve-extension";

/** Read-only repository exploration for motion and interaction audits. */
export default githubExtension({
  connector: "github/freedom-agents-github",
  preset: "repo-explorer",
});
