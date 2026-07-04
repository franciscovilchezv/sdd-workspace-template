# specs/ — <workspace-name> workspace

Spec-driven development for the work done in this workspace. A **spec** describes intended
behavior *before* it's built and is the source of truth that drives implementation.

These specs live at the **workspace level**, deliberately **not** inside the linked repo(s).
Those repos have their own teams, conventions, and tooling; we drive our work spec-first
without adding a `specs/` workflow to them. Specs reference workspace docs
([`../CONTEXT.md`](../CONTEXT.md)) and each repo's own `CLAUDE.md` for architecture.

> This is the **workspace-level** spec model. If instead this workspace uses the **per-repo**
> model (specs versioned inside each linked repo), delete this `specs/` directory — the spec
> workflow then lives in each repo's own `specs/README.md`. See the workspace `README.md`.

## Workflow

1. Copy the template:
   ```bash
   cp specs/_TEMPLATE.md specs/<short-feature-name>.md
   ```
2. Fill it in (Goal, acceptance criteria, changes, schema changes, out of scope).
3. Implement against it:
   ```
   implement @specs/<short-feature-name>.md
   ```
4. Once it's fully implemented, move it to `specs/done/`:
   ```bash
   mv specs/<short-feature-name>.md specs/done/
   ```

## Conventions

- One file per feature, kebab-case (e.g. `add-feature-name.md`).
- `_TEMPLATE.md` is the skeleton — copy it, don't implement it.
- Keep acceptance criteria observable and checkable.
- Reference architecture from each repo's `CLAUDE.md`; don't re-explain the system in the spec.
- When an open question gets answered, move it **out** of the **Open questions** section —
  fold the decision into the acceptance criteria / changes (or note it inline). Keep
  **Open questions** listing only what's still undecided.
- Once a spec is fully implemented, **move it to `specs/done/`** (`mv specs/<name>.md specs/done/`).
  `specs/` then lists only what's still in flight; `specs/done/` is the shipped record.

<!-- OPTIONAL E2E BLOCK — keep only if this workspace adopted the Playwright E2E module
     (e2e-playwright/); delete this "## E2E testing" section and the `## E2E coverage` step in
     `_TEMPLATE.md` otherwise. -->
## E2E testing

- The workspace owns a Playwright E2E suite at the workspace-root `e2e/`, run with
  `npm run test:e2e` from the workspace root. It lives here (not in the linked repo) and drives
  the running app as a black box, so it never imports app source. Setup and rationale:
  [`../e2e-playwright/README.md`](../e2e-playwright/README.md) (or wherever you kept the module's
  README after adopting it).
- **Definition of done includes E2E:** a spec's browser-observable acceptance criteria must have
  a passing `e2e/<slug>.spec.ts` before it moves to `specs/done/`. Spec files stay **flat** at the
  `e2e/` root with a **unique** slug (non-spec helpers live in `e2e/support/`), so the spec→test
  mapping stays greppable even if the list is later grouped into subfolders (`e2e/**/<slug>.spec.ts`).
  Each spec's **`## E2E coverage`** section says what's covered by Playwright vs. left to the repo's
  own unit/component tests. Unit-only specs need no E2E file.
- **Failing-test triage** — a red E2E test routes to exactly one of three fixes by root cause:
  1. the app **code** (most common — reality doesn't match the spec, so fix the app),
  2. the **test** (stale selector / race — patch the test), or
  3. the **spec** (only when a human decides the requirement itself was wrong — re-plan).

  Never make a red test green by weakening the spec or an assertion to match a bug. The spec is
  the fixed point that code and tests move toward, not the thing that moves.
