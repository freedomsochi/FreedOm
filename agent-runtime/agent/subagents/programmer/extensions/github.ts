import githubExtension from "@github-tools/eve-extension";

/**
 * The programmer is the only subagent allowed to propose repository writes.
 * Keep the surface to repository exploration and PR authoring; do not expose
 * merge, branch deletion, repository administration, or unrelated issue tools.
 * The extension's default approval gates remain enabled for all writes.
 */
export default githubExtension({
  connector: "github/freedom-agents-github",
  preset: ["repo-explorer", "pr-author"],
  exclude: [
    "deleteBranch",
    "updatePullRequest",
    "replyToReviewComment",
    "resolveReviewThread",
  ],
});
