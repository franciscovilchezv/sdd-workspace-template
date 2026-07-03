import path from "node:path";

/**
 * Seeded app test users. In the reference setup the app's own seed/migrations
 * create a cast of role-based users that all share ONE password
 * (E2E_USER_PASSWORD in .env.e2e). ADAPT this registry to your app: rename the
 * roles, swap the emails/usernames, and — if your users don't share a password
 * — change auth.setup.ts and .env.e2e to carry per-user secrets or tokens.
 *
 * Emails/usernames are NOT secret (they live in the app's seed data), so they
 * belong in code here rather than in env. A test picks the role it needs by
 * name; nobody edits env per feature.
 *
 * DELETE this file (and auth.setup.ts) for unauthenticated-only suites.
 */
export const SEED_USERS = {
  admin: "<admin-user@example.com>",
  // Add one entry per seeded role your app exposes, e.g.:
  // editor: "<editor-user@example.com>",
  // viewer: "<viewer-user@example.com>",
} as const;

export type Role = keyof typeof SEED_USERS;

/** The default role for authed tests that don't care which user they run as. */
export const DEFAULT_ROLE: Role = "admin";

/** Storage-state file holding a role's saved session (written by auth.setup.ts). */
export const authFile = (role: Role): string =>
  path.join(__dirname, "..", "playwright/.auth", `${role}.json`);

/** The shared seed password, from env. Throws with guidance if unset. */
export function seedPassword(): string {
  const password = process.env.E2E_USER_PASSWORD;
  if (!password) {
    throw new Error(
      "Missing E2E_USER_PASSWORD. Copy .env.e2e.example to .env.e2e and set it " +
        "to the app's shared seed password.",
    );
  }
  return password;
}
