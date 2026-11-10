import { eveChannel } from "eve/channels/eve";
import { localDev, none } from "eve/channels/auth";

/**
 * Access boundary: the freedom-agents Vercel project has Vercel Authentication
 * enabled for all deployment URLs except custom domains. Keep the Web Chat
 * and /eve/v1 API on the same project origin, and do not add an unprotected
 * custom domain.
 *
 * Vercel Deployment Protection authenticates every incoming request before
 * it reaches this channel. `none()` is intentional only behind that
 * edge protection; never disable project SSO while this policy is active.
 */
export default eveChannel({ auth: [localDev(), none()] });
