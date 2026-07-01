# SDD workspace template

Reusable scaffolding for a **Claude Code workspace hub** that drives one or more code repos
**spec-first**, without modifying those repos. Captures three practices:

1. **Symlink workspace** — a thin workspace folder that links sibling repos via `../../<repo>`
   symlinks, so Claude Code (and your editor) see them together while each repo keeps its own
   `.git`, deps, and conventions.
2. **Spec-driven development (SDD)** — features are written as specs *before* implementation,
   then implemented against. Specs are the source of truth.
3. **Workspace-level specs** — specs live in the *workspace's* `specs/`, **not** inside the
   linked repos. This keeps the repos' teams/conventions untouched while you still work
   spec-first.

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
./new-workspace.sh <parent-dir> <workspace-name> <repo> [<repo2> ...]
```

This copies `template/` into `<parent>/workspaces/<workspace-name>/`, creates a `../../<repo>`
symlink for each repo, and verifies the symlinks resolve. Then fill in the `<...>` placeholders
in `CLAUDE.md`, `CONTEXT.md`, `README.md`, `.claude/settings.json`, and `.vscode/settings.json`.

Option B — manual: copy `template/` to your workspace folder, create the symlinks, replace
placeholders.

## Files in `template/`

- `CLAUDE.md` — workspace rules (auto-loaded by Claude Code).
- `CONTEXT.md` — domain/architecture summary (read manually).
- `README.md` — workspace layout + setup.
- `specs/README.md`, `specs/_TEMPLATE.md`, `specs/done/` — the SDD workflow.
- `.claude/settings.json` / `.claude/settings.local.json` — permission allowlist.
- `.vscode/settings.json` — multi-repo editor config.
- `.gitignore` — ignores local settings + notes the symlinks.

Replace every `<placeholder>` (e.g. `<workspace-name>`, `<repo>`, `<project / product name>`).
