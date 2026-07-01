# SDD workspace template

Reusable scaffolding for a **Claude Code workspace hub** that drives one or more code repos
**spec-first**, without modifying those repos. Captures three practices:

1. **Symlink workspace** — a thin workspace folder that links sibling repos via `../../<repo>`
   symlinks, so Claude Code (and your editor) see them together while each repo keeps its own
   `.git`, deps, and conventions.
2. **Spec-driven development (SDD)** — features are written as specs *before* implementation,
   then implemented against. Specs are the source of truth.
3. **A choice of spec placement** — each workspace picks one of two models:
   - **workspace-level** — specs live in the *workspace's* `specs/`, **not** inside the linked
     repos, keeping the repos' teams/conventions untouched while you still work spec-first; or
   - **per-repo** — specs live inside each linked repo's own `specs/` (versioned with that
     repo), with cross-repo features getting a companion spec per repo (one marked lead).

## Expected on-disk layout

```
<parent>/
├── <repo>/                      # your real code repo (own .git)
└── workspaces/
    └── <workspace-name>/        # a copy of template/, with placeholders filled in
        └── <repo> -> ../../<repo>
```

## Use it

Option A — script:

```bash
./new-workspace.sh [--specs workspace|per-repo] <parent-dir> <workspace-name> <repo> [<repo2> ...]
```

This copies `template/` into `<parent>/workspaces/<workspace-name>/`, creates a `../../<repo>`
symlink for each repo, and verifies the symlinks resolve. `--specs` (default `workspace`) picks
the spec model: `workspace` keeps the workspace's `specs/`; `per-repo` removes it and scaffolds
a `specs/` inside each linked repo instead. Then fill in the `<...>` placeholders in
`CLAUDE.md`, `CONTEXT.md`, `README.md`, `.claude/settings.json`, and `.vscode/settings.json`,
and delete the spec-model paragraph that doesn't apply in `CLAUDE.md` / `README.md`.

Option B — manual: copy `template/` to your workspace folder, create the symlinks, replace
placeholders. For the per-repo model, delete the workspace's `specs/` and copy
`spec-model-per-repo/` into each linked repo's `specs/` instead.

## Files

In `template/` (copied into each new workspace):

- `CLAUDE.md` — workspace rules (auto-loaded by Claude Code).
- `CONTEXT.md` — domain/architecture summary (read manually).
- `README.md` — workspace layout + setup.
- `specs/README.md`, `specs/_TEMPLATE.md`, `specs/done/` — the workspace-level SDD workflow.
- `.claude/settings.json` / `.claude/settings.local.json` — permission allowlist.
- `.vscode/settings.json` — multi-repo editor config.
- `.gitignore` — ignores local settings + notes the symlinks.

At the template-repo root (source for the per-repo model; not copied wholesale):

- `spec-model-per-repo/README.md`, `spec-model-per-repo/_TEMPLATE.md` — the per-repo SDD
  scaffold, dropped into each linked repo's `specs/` when you choose `--specs per-repo`.

Replace every `<placeholder>` (e.g. `<workspace-name>`, `<repo>`, `<project / product name>`).
