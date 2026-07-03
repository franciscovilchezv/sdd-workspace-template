import { test as setup, expect } from "@playwright/test";
import { SEED_USERS, authFile, seedPassword, type Role } from "./roles";

/**
 * Auth setup — runs (in parallel) before the authenticated project.
 *
 * Logs in as EACH seeded role once through the real login form and saves that
 * role's session to its own storageState file. Authenticated tests then pick a
 * role by name (see e2e/authed/example.spec.ts) and start already signed in —
 * no per-test login, and no editing env to switch users.
 *
 * ADAPT the selectors and post-login assertion to your app:
 *   - the login route ("/login" below),
 *   - the field/button locators (use stable data-testids or roles), and
 *   - the URL the app lands on after a successful sign-in ("/dashboard" below).
 * If your app has MFA, extend this step to satisfy it (e.g. a test-only bypass
 * or a seeded TOTP secret) before saving storageState.
 *
 * DELETE this file (and roles.ts) for unauthenticated-only suites.
 */
for (const role of Object.keys(SEED_USERS) as Role[]) {
  setup(`authenticate: ${role}`, async ({ page }) => {
    await page.goto("/login");
    await page.getByTestId("<login-email-input>").fill(SEED_USERS[role]);
    await page.getByTestId("<login-password-input>").fill(seedPassword());
    await page.getByTestId("<login-submit-button>").click();

    // Successful sign-in lands on the app's post-login route. Fail loudly
    // (rather than sitting on /login with an error) if the credentials are
    // wrong or the user is unseeded.
    await page.waitForURL("**/dashboard**");
    await expect(page).toHaveURL(/\/dashboard/);

    await page.context().storageState({ path: authFile(role) });
  });
}
