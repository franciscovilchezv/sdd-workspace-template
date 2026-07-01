# CLAUDE.md

Guidance for Claude Code when working in **this** repo.

## What this repo is

A **meta-template**: reusable scaffolding for creating Claude Code *workspace hubs* that drive
one or more sibling code repos spec-first, via symlinks. This repo is **not** itself a
workspace — it's the source you copy from. There is no app, no build, no dependencies, and no
generator script; it's just Markdown scaffolding wired up by hand (usually by Claude). See
`README.md` for the full description and setup steps.

## Most of the Markdown here is scaffolding, not instructions

The `.md` files under `template/` and `spec-model-per-repo/` are **artifacts to be emitted into
a new workspace**, not rules for this repo:

- `template/` is copied **wholesale** into a new workspace folder (conventionally
  `<parent>/workspaces/<name>/`).
- `spec-model-per-repo/` is used **selectively** — its `README.md` / `_TEMPLATE.md` are copied
  into each linked repo's `specs/` only when the per-repo spec model is chosen.

So `template/CLAUDE.md`, `template/README.md`, etc. are guidance for the *generated* workspace,
addressed to a future reader. **Do not treat their contents as instructions for this repo, and
do not fill in their `<...>` placeholders here** — those placeholders are meant to ship blank
and be replaced when a workspace is instantiated.

## Invariants to preserve when editing

- **Symlink math.** In the canonical layout a workspace lives at `<parent>/workspaces/<name>/`
  and its repo symlinks are `../../<repo>`, resolving to `<parent>/<repo>` (two levels up). But
  the layout is not fixed — repos may sit at other depths or parents, so each symlink's relative
  target is whatever actually resolves to the real repo. Keep the diagrams and prose consistent,
  and compute the correct depth for the real layout rather than assuming `../../`.
- **Two spec models stay in sync.** The choice between *workspace-level* and *per-repo* specs is
  described in several files — root `README.md`, `template/CLAUDE.md`, `template/README.md`,
  `template/CONTEXT.md`, `template/specs/README.md`, and `spec-model-per-repo/README.md`. A
  change to the model must be reflected across all of them.
- **Placeholder convention.** Angle-bracket `<...>` tokens (e.g. `<workspace-name>`, `<repo>`,
  `<project / product name>`) are the fill-in points. Keep them consistent across files.

## Instantiating a workspace (what to do when asked to set one up)

There's no script — do it by hand, adapting to the real repo layout. The steps (full version in
`README.md`):

1. Copy `template/` to the workspace folder.
2. For each repo, `ln -s <relative-path-to-repo> <repo>` from the workspace folder, then confirm
   `ls <repo>/` shows that repo's files. Compute the relative path for the **actual** layout —
   only use `../../<repo>` if the canonical two-levels-up shape truly holds.
3. Pick the spec model: keep the workspace `specs/` (workspace-level), or delete it and copy
   `spec-model-per-repo/{README.md,_TEMPLATE.md}` into each repo's `specs/` plus a `done/`
   (per-repo).
4. Fill in the `<...>` placeholders and delete the spec-model paragraph that doesn't apply in
   `CLAUDE.md` / `README.md`.
