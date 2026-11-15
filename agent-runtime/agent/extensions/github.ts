import githubExtension from "@github-tools/eve-extension";

/**
 * The coordinator only inspects the repository and reviews specialist output.
 * Code writes belong exclusively to the programmer subagent.
 */
export default githubExtension({
  connector: "github/freedom-agents-github",
  preset: "repo-explorer",
});
