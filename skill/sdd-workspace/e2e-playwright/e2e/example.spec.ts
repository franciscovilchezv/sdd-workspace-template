import { test, expect } from "@playwright/test";

/**
 * Sample UNAUTHENTICATED E2E test — workspace-level suite.
 *
 * Replace this with a real deterministic signed-out flow for your app (e.g. a
 * public landing page, or the root redirecting anonymous users to a login
 * route). It drives the app as a black box: navigate URLs, assert on the DOM,
 * never import app source. Delete this file once you have real coverage.
 */
test.describe("unauthenticated entry", () => {
  test("root loads the expected signed-out page", async ({ page }) => {
    await page.goto("/");
    // Assert on whatever is deterministic when signed out, e.g.:
    // await expect(page).toHaveURL(/\/login/);
    await expect(page).toHaveTitle(/.*/);
  });
});
