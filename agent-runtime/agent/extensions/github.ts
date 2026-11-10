import githubExtension from "@github-tools/eve-extension";

/**
 * FreeDom repository tools.
 * Connector access is limited by the GitHub App installation.
 * GitHub write tools keep the extension's default durable approval gate.
 */
export default githubExtension({
  connector: "github/freedom-agents-github",
  preset: "maintainer",
  exclude: ["createGist", "deleteGist", "getGist", "listGists", "updateGist"],
});
