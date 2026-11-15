import githubExtension from "@github-tools/eve-extension";

/**
 * The programmer is the only subagent allowed to write application code.
 * The extension's built-in approval gates remain enabled for GitHub writes.
 */
export default githubExtension({
  connector: "github/freedom-agents-github",
  preset: "maintainer",
  exclude: ["createGist", "deleteGist", "getGist", "listGists", "updateGist"],
});
