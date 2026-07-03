import { defineConfig, devices } from "@playwright/test";
import path from "node:path";
import dotenv from "dotenv";
// The authFile / DEFAULT_ROLE import and the `setup` + `chromium-authed`
// projects below are only needed for AUTHENTICATED tests. If this workspace's
// E2E is unauthenticated-only, delete e2e/roles.ts + e2e/auth.setup.ts, drop
// this import, and remove those two projects. See README.md.
import { authFile, DEFAULT_ROLE } from "./e2e/roles";

// Credentials for authenticated tests live in .env.e2e (gitignored). See
// .env.e2e.example. Absent in unauthenticated-only runs — that's fine.
dotenv.config({ path: path.resolve(__dirname, ".env.e2e") });

/**
 * Workspace-level Playwright config for the <workspace-name> SDD workspace.
 *
 * These E2E tests live HERE, not in the linked <app-repo> repo, and drive the
 * running app as a black box (navigate URLs, assert on the DOM; never import
 * app source). That black-box nature is what lets them live at the workspace
 * level alongside specs/. See the adopting spec for the full rationale.
 *
 * Test layout:
 *   e2e/*.spec.ts         unauthenticated tests (run signed-out)
 *   e2e/authed/*.spec.ts  authenticated tests (reuse a seeded-user session)
 */
export default defineConfig({
  testDir: "./e2e",
  testMatch: ["**/*.spec.ts"],
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  // List output while running + an HTML report (not auto-opened). Every test
  // carries a screenshot, a scrubable trace, and a video (see `use` below), so
  // the report is a full visual record of each run.
  reporter: [["html", { open: "never" }], ["list"]],
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL ?? "http://localhost:3000",
    // Always capture visuals so the HTML report carries a screenshot, a
    // scrubable trace, and a video for every test — passing or failing. Dial
    // these back to "on-first-retry" / "retain-on-failure" if runs get heavy.
    screenshot: "on",
    video: "on",
    trace: "on",
  },

  projects: [
    // Logs in once as each seeded test user and writes per-role storageState.
    // Delete this project (and chromium-authed) for unauthenticated-only suites.
    {
      name: "setup",
      testMatch: /.*\.setup\.ts/,
    },

    // Unauthenticated tests — signed out. Excludes the authed/ folder and the
    // planner's environment seed (e2e/seed.spec.ts is agent tooling, not a test).
    {
      name: "chromium",
      testIgnore: [/authed\//, /seed\.spec\.ts/],
      use: { ...devices["Desktop Chrome"] },
    },

    // Authenticated tests — start already signed in. Defaults to DEFAULT_ROLE;
    // a spec overrides per file with `test.use({ storageState: authFile("<role>") })`.
    {
      name: "chromium-authed",
      testMatch: /authed\/.*\.spec\.ts/,
      dependencies: ["setup"],
      use: { ...devices["Desktop Chrome"], storageState: authFile(DEFAULT_ROLE) },
    },
    // Add Firefox / WebKit variants here when cross-browser coverage is needed.
  ],

  // Boots the app's dev server through the <app-repo>/ symlink. The app needs
  // its own .env to come up. Reuses an already-running dev server locally so you
  // can keep the dev server open in <app-repo>/ while iterating on tests.
  webServer: {
    // Replace <dev-server-cmd> with the app's dev command, e.g. "npm run dev",
    // "bun dev", "pnpm dev". Override at runtime with PLAYWRIGHT_START_CMD.
    command: process.env.PLAYWRIGHT_START_CMD ?? "<dev-server-cmd>",
    cwd: "./<app-repo>",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
