# <workspace-name> workspace

A Claude Code **workspace hub** for working on **<project / product name>**. It contains only
workspace docs, the spec-driven-development workflow, and Claude Code config; the actual code
lives in one or more separate repos, referenced here by their real path — granted to Claude Code
via `permissions.additionalDirectories` in `.claude/settings.json` and listed in
`<workspace-name>.code-workspace` (no symlinks).

## Layout this workspace expects

<!-- Edit this diagram to show where THIS workspace's repos actually live. The common case is
     sibling repos two levels up (../../<repo>); repos may instead be nested in subfolders or
     live elsewhere on disk — whatever real path you grant. -->

This folder lives under `<parent>/workspaces/`; each repo is referenced by its real path wherever
it lives on disk (in the common case, two levels up at a sibling — `../../<repo>`):

```
<parent>/
├── <repo>/                  # a linked code repo (referenced as ../../<repo>)
└── workspaces/
    └── <workspace-name>/    ← this workspace (grants ../../<repo> via additionalDirectories)
```

If you move the workspace (or a repo), update the `../../<repo>` path in `.claude/settings.json`
and `<workspace-name>.code-workspace` so it still resolves (`ls ../../<repo>/` should show that
repo's files).

## Setting up on a new machine

1. Clone the linked repo(s) into `<parent>/`.
2. Place this workspace at `<parent>/workspaces/<workspace-name>`.
3. Verify each path resolves: `ls ../../<repo>/` should show that repo's files.
4. Open Claude Code from this workspace folder — the granted repos are available automatically via
   `.claude/settings.json`. In VS Code, open `<workspace-name>.code-workspace` for the multi-root
   view.

## Spec-driven development

This workspace works spec-first, using **one** of two spec models (see `CLAUDE.md`; keep the
matching paragraph there and delete the other):

- **Workspace-level** — specs live **here**, in `specs/`, intentionally **not** inside the
  linked repo(s), so each repo's own conventions and team workflow stay untouched. Copy
  `specs/_TEMPLATE.md`, fill it in, implement against it, then move it to `specs/done/`. See
  `specs/README.md`.
- **Per-repo** — specs live inside each linked repo's own `specs/` (versioned with that repo);
  cross-repo features get a companion spec per repo, one marked lead. In this model the
  workspace has no `specs/` — see each repo's `specs/README.md`.

## E2E testing (optional)

If a linked repo is a browser-facing web app, this workspace can own a **workspace-level
Playwright E2E suite** — tests that live here (not in the repo) and drive the running app as a
black box, so a spec's browser-observable acceptance criteria are covered before it moves to
`specs/done/`. It's added from the template's optional `e2e-playwright/` module (config, agents,
auth harness). If this workspace adopted it, `npm run test:e2e` from the workspace root runs the
suite; see the module's `README.md`. Delete this section if the workspace has no E2E suite.

## Files

- `CLAUDE.md` — workspace rules (auto-loaded by Claude Code).
- `CONTEXT.md` — domain context and architecture summary (read manually).
- `specs/` — the SDD workflow (workspace-level model only; template, README, `done/`).
- `.claude/settings.json` — shared config: the `additionalDirectories` grant for the linked repos
  plus a machine-agnostic permission allowlist.
- `.claude/settings.local.json` — per-machine settings; **gitignored**, not shared.
- `<workspace-name>.code-workspace` — VS Code multi-root file listing this workspace and each
  linked repo by its real path.
- `e2e/`, `playwright.config.ts`, `package.json`, `.mcp.json` — the Playwright E2E suite, **only
  if** the optional `e2e-playwright/` module was adopted; otherwise absent.
