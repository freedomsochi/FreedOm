import githubExtension from "@github-tools/eve-extension";

/** Read-only repository exploration for independent code review and test planning. */
export default githubExtension({
  connector: "github/freedom-agents-github",
  preset: "repo-explorer",
});
