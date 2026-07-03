# `e2e-playwright/` — optional workspace-level E2E module

Reusable scaffolding for adding a **workspace-level Playwright E2E suite** to a workspace hub.
Like the workspace itself, the tests live at the **workspace level** — deliberately **not**
inside the linked repo — and drive the running app as a **black box** (navigate URLs, assert on
the DOM, never `import` app source). That black-box nature is exactly what lets them sit next to
`specs/` instead of inside the repo, so the repo's own team, conventions, and pinned Playwright
version stay untouched. It also lets the workspace run a **newer** Playwright than the repo pins.

This module is **optional and selective** — copy it into a workspace only when a linked repo is a
browser-facing web app you want to drive end-to-end. It is not copied by the wholesale `template/`
copy. Skip it entirely for library/CLI/back-end-only workspaces.

## When to adopt

- A linked repo serves a web UI you can reach over HTTP.
- You want a spec's **browser-observable** acceptance criteria backed by a passing E2E test as
  part of its definition of done.

If the repo already owns a healthy E2E suite its team runs, prefer that — this module exists so
the *workspace* can add coverage **without changing the repo**.

## Choose an authoring loop: MCP or agent CLI

The **runner** (config, `e2e/` harness, auth setup) is shared. What differs is **how tests get
authored** — pick one:

| | **MCP** (`authoring-mcp/`) | **Agent CLI** (`authoring-cli/`) |
|---|---|---|
| Tool | Playwright MCP + `init-agents` subagents | Playwright agent CLI (`@playwright/cli`, `playwright-cli`) |
| Loop | Structured MCP tools; planner/generator/healer subagents | Shell commands (`playwright-cli open/click/fill/snapshot/state-save`) + installed skill docs |
| Scaffolds | `.mcp.json` + 3 pre-modified agents (shipped here) | `.claude/skills/playwright-cli/` via `playwright-cli install --skills` (run at adoption) |
| Subagents | Yes (planner/generator/healer) | No — the loop is documented in `CLAUDE.md` |
| Trade-off | Structured, discoverable tool calls | Lower-token, shell-native; verifies selectors against the live DOM per command |

Both produce the same deliverable: a passing `e2e/<slug>.spec.ts` per spec. Adopt **exactly one**
— then follow that subdir's `README.md`. If unsure, the CLI loop is the lighter-weight default;
the MCP loop suits teams that prefer structured subagents.

## Shared files (copied for either loop)

| File | Role |
|---|---|
| `playwright.config.ts` | `testDir: ./e2e`, `webServer` boots the app via the `<app-repo>/` symlink, `list` + HTML reporters, screenshot/video/trace **on** for every test. |
| `.env.e2e.example` | Template for the one secret authenticated tests need. Copy to `.env.e2e` (gitignored). |
| `e2e/example.spec.ts` | Sample **unauthenticated** test — replace with a real signed-out flow. |
| `e2e/authed/example.spec.ts` | Sample **authenticated** test — starts already signed in via saved session. |
| `e2e/roles.ts` | Seeded-user registry + `authFile`/`seedPassword` helpers. **Adapt to your app's auth.** Authenticated suites only. |
| `e2e/auth.setup.ts` | Setup project: logs each role in once, saves per-role `storageState`. **Adapt selectors + post-login URL.** Authenticated suites only. |
| `gitignore-additions.txt` | Lines to append to the workspace `.gitignore`. |

Then, from your chosen loop's subdir: `package.json` (approach-flavored) plus its authoring
scaffolds. Everything uses `<placeholder>` tokens (`<workspace-name>`, `<app-repo>`,
`<dev-server-cmd>`, `<login-*>` test ids, seeded emails) — fill them in for the real app.

## Adoption steps

Run these from the workspace folder (the copy of `template/`).

1. **Copy the shared files in.** Copy `playwright.config.ts`, `.env.e2e.example`, `e2e/`, and
   `gitignore-additions.txt` (as `.gitignore` additions) into the workspace root.

2. **Copy your chosen loop.** From `authoring-mcp/` **or** `authoring-cli/`, copy its
   `package.json` into the workspace root, then follow that subdir's `README.md` for its
   authoring scaffolds (`.mcp.json` + `.claude/agents/` for MCP; `playwright-cli install --skills`
   for CLI).

3. **Fill placeholders.** In `playwright.config.ts` set `<app-repo>` (the symlink name of the
   web app), `<dev-server-cmd>` (e.g. `npm run dev` / `bun dev`), and the `url`/`baseURL` port if
   not 3000. In `package.json` set `<workspace-name>`.

4. **Wire gitignore.** Append `gitignore-additions.txt` to the workspace `.gitignore`.

5. **Install + browsers.**
   ```bash
   npm install            # or bun install / pnpm install
   npx playwright install # download browser binaries (CLI loop: npm run pw:install)
   ```

6. **Unauthenticated first.** Point `e2e/example.spec.ts` at a real deterministic signed-out
   flow and get it green:
   ```bash
   npm run test:e2e       # boots the app's dev server via the symlink
   ```

7. **Authenticated (optional).** If features need a signed-in user:
   - Adapt `e2e/roles.ts` to your app's seeded users (roles, emails/usernames, shared-vs-per-user
     password). For unauthenticated-only suites, **delete** `roles.ts` + `auth.setup.ts` and the
     `setup`/`chromium-authed` projects in `playwright.config.ts`.
   - Adapt `e2e/auth.setup.ts` selectors, the login route, and the post-login URL assertion. Add
     MFA handling here if the app has it.
   - `cp .env.e2e.example .env.e2e` and set `E2E_USER_PASSWORD`.
   - A test declares its role with `test.use({ storageState: authFile("<role>") })`; it never
     edits env to switch users.

8. **Fold E2E into the SDD docs.** Adopt the "delete-if-unused" E2E blocks that ship in the
   workspace `CLAUDE.md`, `specs/README.md`, and `specs/_TEMPLATE.md` (`## E2E coverage`). They
   encode the definition-of-done and failing-test triage rule below. In `CLAUDE.md`, keep the
   authoring-loop line for the loop you picked (MCP vs CLI).

## Definition of done + failing-test triage

Once adopted, these become part of the workspace's SDD workflow (identical for both loops):

- **E2E is part of done.** A spec's **browser-observable** acceptance criteria must have a passing
  `e2e/<slug>.spec.ts` (same kebab slug as the spec) before it moves to `specs/done/`. Unit-only
  specs (schema/logic, no browser-facing behavior) need **no** E2E file — don't generate empty
  ones. Each spec's `## E2E coverage` section records what's covered here vs. left to the repo's
  own unit/component tests.
- **Triage a red test to exactly one fix, by root cause:** (1) the app **code** (most common —
  reality doesn't match the spec, so fix the app), (2) the **test** (stale selector / race — patch
  the test), or (3) the **spec** (only when a human decides the requirement itself was wrong —
  re-plan). **Never** make a red test green by weakening the spec or an assertion to match a bug.
  The spec is the fixed point that code and tests move toward, not the thing that moves.
