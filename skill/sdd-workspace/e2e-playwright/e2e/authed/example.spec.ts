import { test, expect } from "@playwright/test";
import { authFile } from "../support/roles";

/**
 * Sample AUTHENTICATED E2E tests.
 *
 * Tests under e2e/authed/ run in the "chromium-authed" project and start
 * already signed in — no login step here. By default they run as DEFAULT_ROLE.
 * To test a feature as a specific seeded role, override per file:
 *
 *   test.use({ storageState: authFile("<role>") });
 *
 * You never edit env to switch users — the role is declared in the test.
 * Replace this with real coverage and delete the sample. (Delete the whole
 * authed/ folder for unauthenticated-only suites.)
 */
test.describe("authenticated entry (default role)", () => {
  test("signed-in user reaches an authenticated page", async ({ page }) => {
    await page.goto("/dashboard");
    await expect(page).toHaveURL(/\/dashboard/);
  });
});

test.describe("authenticated entry (as a specific role)", () => {
  // Demonstrates a per-feature role override.
  test.use({ storageState: authFile("admin") });

  test("role-specific user reaches an authenticated page", async ({ page }) => {
    await page.goto("/dashboard");
    await expect(page).toHaveURL(/\/dashboard/);
  });
});
