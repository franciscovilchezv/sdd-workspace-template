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

Optionally, a workspace driving a browser-facing web app can add a **workspace-level Playwright
E2E suite** (the `e2e-playwright/` module): black-box tests that live in the workspace, drive the
running app over HTTP/DOM without importing its source, and make a spec's browser-observable
acceptance criteria part of its definition of done. It ships a shared runner (config +
authenticated-session harness) and a **choice of authoring loop** — the **Playwright MCP**
(`init-agents` planner/generator/healer subagents, pre-wired to keep generated test plans out of
the SDD `specs/`) or the **Playwright agent CLI** (`@playwright/cli` + installed skill docs, no
subagents). Pick one. See `skill/sdd-workspace/e2e-playwright/README.md`.

## Expected on-disk layout

The **canonical** shape (as in the reference workspaces) is a shared parent with the repos flat
beside a `workspaces/` folder. But repos don't have to be flat siblings — they can be nested in
subfolders, or live somewhere else entirely; each symlink just has to resolve to the real repo:

```
<parent>/
├── <repo>/                          # a repo as a flat sibling (canonical)
├── <group>/
│   └── <nested-repo>/               # …or nested inside a subfolder
└── workspaces/
    └── <workspace-name>/            # a copy of skill/sdd-workspace/template/, placeholders filled in
        ├── <repo>        -> ../../<repo>
        └── <nested-repo> -> ../../<group>/<nested-repo>

/elsewhere/<external-repo>/          # …or outside <parent> altogether
#   (symlinked as  <external-repo> -> /elsewhere/<external-repo>)
```

The only hard requirement is that each `<repo>` symlink resolves to the real repo — its target
is whatever relative or absolute path points there from the workspace folder.

## Set up a workspace

There's no generator script — you wire a workspace up by hand, or (more usually) let Claude Code
do it, so the result matches whatever the real repos actually look like. All the scaffolding lives
under **`skill/sdd-workspace/`** (there's no second copy at the repo root). The easiest path is to
install the bundled skill and just ask; the numbered **Manual steps** below are the underlying
procedure, which both flows run.

### Install the skill (recommended)

Install the bundled Claude Code skill once, then describe workspaces in any session — no cloning,
no pointing at this repo:

```bash
cp -R skill/sdd-workspace ~/.claude/skills/sdd-workspace   # or a repo's .claude/skills/
```

Then, in a session opened where the workspace should live:

> Set up an SDD workspace named `checkout-flow` linking `/Users/me/git/api-service` and
> `/Users/me/git/web-app`, per-repo spec model.

The skill runs the manual steps below against the paths you give it. See `skill/README.md`.

### Without the skill: ask Claude to clone this repo

If you'd rather not install the skill, open Claude Code where the workspace should live, point it
at this repo, and describe the workspace. For example:

> Set up a new SDD workspace using the template at
> `https://github.com/franciscovilchezv/sdd-workspace-template` — clone it, read its README, and
> follow it. Name the workspace `checkout-flow` and link these repos, using the per-repo spec
> model:
> - `/Users/me/git/api-service`
> - `/Users/me/git/web-app`
> - `/Users/me/git/worker`
>
> Fill in the placeholders from what you find in those repos; leave any `<...>` you can't
> determine for me to complete.

Claude clones this repo (for the bundled scaffolding under `skill/sdd-workspace/`), then carries
out the manual steps below against the paths you gave it.

### Manual steps

With the skill installed, the scaffolding is already on disk — skip straight to step 1. Otherwise,
if you only have this repo's URL, first clone it — `git clone --depth 1 <url>` into a scratch
dir — so you have the scaffolding under `skill/sdd-workspace/` (`template/`,
`spec-model-per-repo/`) to copy from. That clone is throwaway; nothing in the finished workspace
links back to it.

1. **Copy the template.** Copy `skill/sdd-workspace/template/` to your workspace folder — conventionally
   `<parent>/workspaces/<workspace-name>/`, but anywhere works as long as the symlinks resolve.
2. **Symlink each repo.** From the workspace folder, create one symlink per repo, named after
   the repo, pointing at wherever the real repo actually lives:
   ```bash
   ln -s ../../<repo>                 <repo>            # flat sibling (canonical)
   ln -s ../../<group>/<nested-repo>  <nested-repo>     # nested in a subfolder
   ln -s /elsewhere/<external-repo>   <external-repo>   # anywhere on disk (absolute)
   ```
   Pick each target per repo — a relative path (any depth) or an absolute one. The only test is
   that `ls <repo>/` from the workspace shows that repo's files.
3. **Pick a spec model.**
   - *Workspace-level* (default): keep the workspace's `specs/`.
   - *Per-repo*: delete the workspace's `specs/`, then copy
     `skill/sdd-workspace/spec-model-per-repo/README.md` and `_TEMPLATE.md` into each linked repo's
     own `specs/` (add a `specs/done/` too).
4. **Optionally add E2E.** If a linked repo is a browser-facing web app and you want
   workspace-level E2E, adopt the `skill/sdd-workspace/e2e-playwright/` module — follow its `README.md` (copy the
   config/agents/harness in, fill placeholders, append its gitignore lines) and keep the optional
   E2E blocks in the workspace docs. Otherwise delete those *delete-if-unused* blocks.
5. **Optionally add the `@`-mention suggester.** If you want `@<repo>/…` to autocomplete into the
   linked repos (the built-in picker can't reach through the symlinks) and have `fd` installed,
   adopt the `skill/sdd-workspace/at-mention-suggester/` module — follow its `README.md` (copy
   `file-suggestion.sh` into `.claude/`, add the `fileSuggestion` block to `.claude/settings.json`,
   paste its `CLAUDE.md` note). Otherwise skip it.
6. **Fill in placeholders.** Replace the `<...>` tokens in `CLAUDE.md`, `CONTEXT.md`,
   `README.md`, `.claude/settings.json`, and `.vscode/settings.json`, and delete the spec-model
   paragraph that doesn't apply in `CLAUDE.md` / `README.md`.

## Files

All scaffolding lives under `skill/sdd-workspace/`.

In `skill/sdd-workspace/template/` (copied into each new workspace):

- `CLAUDE.md` — workspace rules (auto-loaded by Claude Code).
- `CONTEXT.md` — domain/architecture summary (read manually).
- `README.md` — workspace layout + setup.
- `specs/README.md`, `specs/_TEMPLATE.md`, `specs/done/` — the workspace-level SDD workflow.
- `.claude/settings.json` / `.claude/settings.local.json` — permission allowlist.
- `.vscode/settings.json` — multi-repo editor config.
- `.gitignore` — ignores local settings + notes the symlinks.

Alongside it under `skill/sdd-workspace/` (selective sources; not copied wholesale):

- `spec-model-per-repo/README.md`, `spec-model-per-repo/_TEMPLATE.md` — the per-repo SDD
  scaffold, copied into each linked repo's `specs/` when you choose the per-repo model.
- `e2e-playwright/` — the optional workspace-level Playwright E2E module: a shared runner (config
  + `e2e/` authenticated-session harness) plus two interchangeable authoring loops,
  `authoring-mcp/` (`.mcp.json` + `init-agents` agents) and `authoring-cli/` (`@playwright/cli` +
  installed skills). Copied into the workspace only when it drives a web app; pick one loop.
- `at-mention-suggester/` — an optional `@`-mention file suggester (`file-suggestion.sh` +
  adoption `README.md`). The built-in `@` picker can't descend into the repo symlinks; this
  drop-in `fileSuggestion` script does an `fd --follow` walk so `@<repo>/…` autocompletes into the
  linked repos. Repo-agnostic (no placeholders); opt-in because it needs `fd` on `PATH`.

Replace every `<placeholder>` (e.g. `<workspace-name>`, `<repo>`, `<project / product name>`).
