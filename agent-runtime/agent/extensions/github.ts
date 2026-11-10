import githubExtension from "@github-tools/eve-extension";

/**
 * GitHub access for the FreeDom coordinator and its specialists.
 *
 * The connector is restricted at the Vercel/GitHub installation level to
 * freedomsochi/FreedOm. All write operations require human approval by
 * default; the critical repository mutations below are explicitly gated.
 */
export default githubExtension({
  connector: "github/freedom-agents-github",
  preset: "maintainer",
  requireApproval: {
    createBranch: true,
    createOrUpdateFile: true,
    createPullRequest: true,
    updatePullRequest: true,
    mergePullRequest: true,
    deleteBranch: true,
    deleteFile: true,
    createRelease: true,
    publishRelease: true,
  },
});
