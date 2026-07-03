# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this workspace.

## Workspace Overview

This is the **<workspace-name>** workspace — a Claude Code hub for working on
**<project / product name>**.

It links one or more git repositories via symlinks. Each repo has its own `.git`, dependencies,
`.env`, and its own `CLAUDE.md` with detailed architecture notes — **read the repo's `CLAUDE.md`
before working in it.**

| Symlink | Repo | Role | Details |
|---|---|---|---|
| `<repo>/` | `../../<repo>` | <one-line role> | `<repo>/CLAUDE.md` |
<!-- add a row per linked repo -->

Always `cd` into the relevant repo directory before running commands.

## Domain context

The product domain and the high-level shape of the system live in `CONTEXT.md` (workspace
root) and, in much more detail, in each repo's `CLAUDE.md`. `CONTEXT.md` is **not**
auto-loaded — read it for any domain-heavy task or when implementing a spec. This file holds
workspace rules.

## Spec-driven development

Feature work is described as a spec before implementation. This workspace uses **one** of two
spec models — **keep the matching paragraph below and delete the other:**

<!-- MODEL A — workspace-level specs -->
**Specs live at the workspace level**, in this workspace's own `specs/` directory —
deliberately **not** inside the linked repo(s). The linked repos have their own teams and
conventions, and we don't want to add a `specs/` workflow to them. Keeping specs here lets us
drive implementation spec-first without changing how those repos' developers work. Copy
`specs/_TEMPLATE.md`, fill it in, and implement against it. See `specs/README.md`.

<!-- MODEL B — per-repo specs (delete MODEL A above and the workspace-level specs/ dir) -->
**Specs live per-repo**, in each linked repo's own `specs/` directory (versioned with that
repo) — not at the workspace level. A feature that spans multiple repos gets a companion spec
in each affected repo, cross-linked, with one marked as the lead. Copy that repo's
`specs/_TEMPLATE.md`, fill it in, and implement against it. See each repo's `specs/README.md`.

<!-- OPTIONAL E2E BLOCK — keep only if this workspace adopted the Playwright E2E module
     (e2e-playwright/); delete this whole "## E2E testing" section otherwise. -->
## E2E testing (Playwright)

The workspace owns a Playwright E2E suite at the workspace-root `e2e/`, run with
`npm run test:e2e` from the **workspace root** (not from inside a linked repo). It lives here
— deliberately not in `<app-repo>` — because E2E tests are black-box: they drive the running app
over HTTP/DOM and never `import` app source, so they have no reason to live in the repo, and the
workspace can run a newer Playwright than the repo's pinned version. The config boots the app's
dev server through the `<app-repo>/` symlink (`webServer.cwd`). The repo's own test setup is left
untouched. Full rationale and adoption notes: `e2e-playwright/README.md`.

<!-- Keep ONE authoring-loop line — whichever this workspace adopted — and delete the other. -->
- **Authoring loop — Playwright MCP:** tests are authored via the `init-agents`
  planner/generator/healer subagents (see `.claude/agents/` + `.mcp.json`); generated test plans
  go under `e2e/specs/`, tests under `e2e/<slug>/`, never into the SDD `specs/`.
- **Authoring loop — Playwright agent CLI (NOT the MCP):** author tests by driving `playwright-cli`
  (`open`/`snapshot`/`click`/`fill`/`state-save`) against the running app to verify selectors, then
  write `e2e/<slug>.spec.ts`. Skills live at `.claude/skills/playwright-cli/` (auto-discovered).
  Do not use the Playwright MCP.

Part of a spec's **definition of done**: its browser-observable acceptance criteria must have a
passing `e2e/<slug>.spec.ts` (same kebab-case slug as the spec) before it moves to `specs/done/`.
Unit-only specs (schema/logic, no browser-facing behavior) need no E2E file — the repo's own unit
suites cover those.

When an E2E test fails, triage the root cause and fix accordingly: the app **code** (usual case),
the **test** (stale selector/race), or — only on a deliberate human call — the **spec**. Never
make a red test green by weakening the spec or an assertion to match a bug.
