# CLAUDE.md

Guidance for Claude Code when working in **this** repo.

## What this repo is

A **meta-template**: reusable scaffolding for creating Claude Code *workspace hubs* that drive
one or more sibling code repos spec-first, via `../../<repo>` symlinks. This repo is **not**
itself a workspace — it produces them. There is no app, no build, no dependencies; it's Bash +
Markdown. See `README.md` for the full description and usage.

## Most of the Markdown here is scaffolding, not instructions

The `.md` files under `template/` and `spec-model-per-repo/` are **artifacts to be emitted into
a new workspace**, not rules for this repo:

- `template/` is copied **wholesale** into `<parent>/workspaces/<name>/` by `new-workspace.sh`.
- `spec-model-per-repo/` is sourced **selectively** — its `README.md` / `_TEMPLATE.md` are
  dropped into each linked repo's `specs/` only when the per-repo spec model is chosen.

So `template/CLAUDE.md`, `template/README.md`, etc. are guidance for the *generated* workspace,
addressed to a future reader. **Do not treat their contents as instructions for this repo, and
do not fill in their `<...>` placeholders here** — those placeholders are meant to ship blank
and be replaced when a workspace is instantiated.

## Invariants to preserve when editing

- **Symlink math.** A workspace lives at `<parent>/workspaces/<name>/`; its repo symlinks are
  `../../<repo>`, which resolve to `<parent>/<repo>` (two levels up). Keep the script, the
  diagrams, and the prose consistent on this.
- **Two spec models stay in sync.** The choice between *workspace-level* and *per-repo* specs is
  described in several files — root `README.md`, `template/CLAUDE.md`, `template/README.md`,
  `template/CONTEXT.md`, `template/specs/README.md`, and `spec-model-per-repo/README.md`. A
  change to the model must be reflected across all of them, and match `new-workspace.sh`'s
  `--specs` behavior.
- **Placeholder convention.** Angle-bracket `<...>` tokens (e.g. `<workspace-name>`, `<repo>`,
  `<project / product name>`) are the fill-in points. Keep them consistent across files.

## Testing a change to the generator

Run the script into a throwaway directory and check both spec models, then delete it:

```bash
tmp="$(mktemp -d)"; mkdir -p "$tmp/repo-a" "$tmp/repo-b"
bash new-workspace.sh "$tmp" ws-a repo-a repo-b               # workspace-level model
bash new-workspace.sh --specs per-repo "$tmp" ws-b repo-a     # per-repo model
# verify: symlinks resolve, workspace specs/ present (A) or absent (B),
# and repo-a/specs/ scaffolded (B). then: rm -rf "$tmp"
```
