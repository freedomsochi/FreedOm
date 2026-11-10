import githubExtension from "@github-tools/eve-extension";

/**
 * FreeDom repository tools.
 * The GitHub App installation is restricted to freedomsochi/FreedOm.
 * Every write tool requires explicit human approval (default Eve extension
 * behavior); repository-changing operations are explicitly gated here too.
 */
export default githubExtension({
  connector: "github/freedom-agents-github",
  preset: "pr-author",
  requireApproval: {
    createBranch: true,
    deleteBranch: true,
    createOrUpdateFile: true,
    createPullRequest: true,
    updatePullRequest: true,
  },
});
