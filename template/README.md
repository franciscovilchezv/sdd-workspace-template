# <workspace-name> workspace

A Claude Code **workspace hub** for working on **<project / product name>**. It contains only
workspace docs, the spec-driven-development workflow, and Claude Code config; the actual code
lives in one or more separate repos, linked here via symlinks.

## Layout this workspace expects

<!-- Edit this diagram to show where THIS workspace's repos actually live. The common case is
     sibling repos two levels up (../../<repo>); repos may instead be nested in subfolders or
     live elsewhere on disk — whatever each symlink resolves to. -->

This folder lives under `<parent>/workspaces/`; each symlink points at a linked repo wherever it
lives on disk (in the common case, two levels up at a sibling — `../../<repo>`):

```
<parent>/
├── <repo>/                  # a linked code repo
└── workspaces/
    └── <workspace-name>/    ← this workspace
        └── <repo>  -> ../../<repo>
```

If you move the workspace (or a repo), the symlinks dangle — recreate the structure above, or
re-point the symlinks, so each `ls <repo>/` resolves.

## Setting up on a new machine

1. Clone the linked repo(s) into `<parent>/`.
2. Place this workspace at `<parent>/workspaces/<workspace-name>`.
3. Verify each symlink resolves: `ls <repo>/` should show that repo's files.
4. Open Claude Code from this workspace folder.

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

## Files

- `CLAUDE.md` — workspace rules (auto-loaded by Claude Code).
- `CONTEXT.md` — domain context and architecture summary (read manually).
- `specs/` — the SDD workflow (workspace-level model only; template, README, `done/`).
- `.claude/settings.json` — shared, machine-agnostic permission allowlist.
- `.claude/settings.local.json` — per-machine settings; **gitignored**, not shared.
