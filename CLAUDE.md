# CLAUDE.md

Guidance for Claude Code when working in **this** repo.

## What this repo is

A **meta-template**: reusable scaffolding for creating Claude Code *workspace hubs* that drive
one or more code repos spec-first, via symlinks (the repos can be siblings, nested in
subfolders, or elsewhere on disk). This repo is **not** itself a
workspace — it's the source you copy from. There is no app, no build, no dependencies, and no
generator script; it's just Markdown scaffolding wired up by hand (usually by Claude).

The scaffolding lives in exactly one place: **`skill/sdd-workspace/`**, packaged as a Claude Code
skill so it's self-contained. Everything a workspace is built from — `template/`,
`spec-model-per-repo/`, and the optional `e2e-playwright/` module — sits under that directory. The
repo root holds only these docs (`README.md`, `CLAUDE.md`) and the skill. See `README.md` for the
full description and setup steps.

## Most of the Markdown here is scaffolding, not instructions

The `.md` files under `skill/sdd-workspace/template/`, `skill/sdd-workspace/spec-model-per-repo/`,
and `skill/sdd-workspace/e2e-playwright/` are **artifacts to be emitted into a new workspace**, not
rules for this repo:

- `skill/sdd-workspace/template/` is copied **wholesale** into a new workspace folder
  (conventionally `<parent>/workspaces/<name>/`).
- `skill/sdd-workspace/spec-model-per-repo/` is used **selectively** — its `README.md` /
  `_TEMPLATE.md` are copied into each linked repo's `specs/` only when the per-repo spec model is
  chosen.
- `skill/sdd-workspace/e2e-playwright/` is used **selectively** — its shared runner (config +
  `e2e/` harness) and **one** of its two authoring loops (`authoring-mcp/` or `authoring-cli/`) are
  copied into the workspace only when a linked repo is a browser-facing app and the workspace
  adopts a workspace-level Playwright E2E suite. Its own `README.md` is the adoption guide, not a
  rule for this repo. Non-web workspaces skip it entirely.

So `template/CLAUDE.md`, `template/README.md`, etc. (under `skill/sdd-workspace/`) are guidance for
the *generated* workspace, addressed to a future reader. **Do not treat their contents as
instructions for this repo, and do not fill in their `<...>` placeholders here** — those
placeholders are meant to ship blank and be replaced when a workspace is instantiated.

## Invariants to preserve when editing

- **Symlink math.** In the canonical layout a workspace lives at `<parent>/workspaces/<name>/`
  and its repo symlinks are `../../<repo>`, resolving to `<parent>/<repo>` (two levels up). But
  the layout is not fixed — repos may sit at other depths or parents, be nested in subfolders,
  or live outside `<parent>` entirely, so each symlink's target (relative *or* absolute) is
  whatever actually resolves to the real repo. Keep the diagrams and prose consistent, and
  compute the correct target for the real layout rather than assuming `../../`.
- **Single source of truth.** All scaffolding lives under `skill/sdd-workspace/` and nowhere else
  — there is no second copy at the repo root to keep in sync. Edit the trees there directly; the
  repo docs (`README.md`, `CLAUDE.md`, `skill/README.md`) point at those paths.
- **Two spec models stay in sync.** The choice between *workspace-level* and *per-repo* specs is
  described in several files — root `README.md`, `skill/sdd-workspace/template/CLAUDE.md`,
  `skill/sdd-workspace/template/README.md`, `skill/sdd-workspace/template/CONTEXT.md`,
  `skill/sdd-workspace/template/specs/README.md`, and
  `skill/sdd-workspace/spec-model-per-repo/README.md`. A change to the model must be reflected
  across all of them.
- **Optional E2E blocks stay in sync and stay optional.** The Playwright E2E module
  (`skill/sdd-workspace/e2e-playwright/`) is opt-in. Its "definition of done + failing-test triage"
  rule and the `## E2E coverage` spec section are described in that module's `README.md` and echoed
  as clearly-marked *delete-if-unused* blocks in `skill/sdd-workspace/template/CLAUDE.md`,
  `.../template/README.md`, `.../template/CONTEXT.md`, `.../template/specs/README.md`, and
  `.../template/specs/_TEMPLATE.md`. A change to the E2E workflow must be reflected across all of
  them, and those blocks must stay marked optional (a non-web workspace deletes them).
- **Two E2E authoring loops, pick one.** The module offers **MCP** (`authoring-mcp/`) and **agent
  CLI** (`authoring-cli/`) as interchangeable authoring loops over a shared runner. They're
  described in `skill/sdd-workspace/e2e-playwright/README.md` + each subdir's `README.md`, and the
  `template/CLAUDE.md` E2E block carries a *keep-one* authoring-loop line for each. A generated
  workspace adopts exactly one loop and keeps only its line; edits to one loop must not silently
  diverge the shared runner or the other loop's parallel docs.
- **Placeholder convention.** Angle-bracket `<...>` tokens (e.g. `<workspace-name>`, `<repo>`,
  `<project / product name>`) are the fill-in points. Keep them consistent across files.

## Instantiating a workspace (what to do when asked to set one up)

There's no script — do it by hand, adapting to the real repo layout. If you were handed only
this repo's URL (Claude opened in the user's `workspaces/` dir), clone it first
(`git clone --depth 1`) to a scratch dir so you have the scaffolding under `skill/sdd-workspace/`
to copy from; that clone is throwaway. The steps (full version in `README.md`):

1. Copy `skill/sdd-workspace/template/` to the workspace folder.
2. For each repo, `ln -s <path-to-repo> <repo>` from the workspace folder (a relative path of any
   depth, or an absolute one), then confirm `ls <repo>/` shows that repo's files. Compute the
   target for the **actual** layout — only use `../../<repo>` if the canonical two-levels-up
   shape truly holds.
3. Pick the spec model: keep the workspace `specs/` (workspace-level), or delete it and copy
   `skill/sdd-workspace/spec-model-per-repo/{README.md,_TEMPLATE.md}` into each repo's `specs/`
   plus a `done/` (per-repo).
4. **Optional E2E:** if a linked repo is a browser-facing web app and the user wants
   workspace-level E2E, adopt the `skill/sdd-workspace/e2e-playwright/` module — follow its
   `README.md` (copy the config/agents/harness into the workspace, fill placeholders, append its
   gitignore lines) and keep the optional E2E blocks in the workspace docs. Otherwise delete those
   delete-if-unused blocks.
5. Fill in the `<...>` placeholders and delete the spec-model paragraph that doesn't apply in
   `CLAUDE.md` / `README.md`.
