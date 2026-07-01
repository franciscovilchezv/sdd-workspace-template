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

The **canonical** shape (as in the reference workspaces) is a shared parent with the repos flat
beside a `workspaces/` folder. But repos don't have to be flat siblings — they can be nested in
subfolders, or live somewhere else entirely; each symlink just has to resolve to the real repo:

```
<parent>/
├── <repo>/                          # a repo as a flat sibling (canonical)
├── <group>/
│   └── <nested-repo>/               # …or nested inside a subfolder
└── workspaces/
    └── <workspace-name>/            # a copy of template/, with placeholders filled in
        ├── <repo>        -> ../../<repo>
        └── <nested-repo> -> ../../<group>/<nested-repo>

/elsewhere/<external-repo>/          # …or outside <parent> altogether
#   (symlinked as  <external-repo> -> /elsewhere/<external-repo>)
```

The only hard requirement is that each `<repo>` symlink resolves to the real repo — its target
is whatever relative or absolute path points there from the workspace folder.

## Set up a workspace

There's no generator script — you wire a workspace up by hand, or (more usually) ask Claude
Code to do it, so the result matches whatever the real repos actually look like.

### Ask Claude (the intended flow)

Open Claude Code in the folder where the workspace should live (e.g. your `workspaces/`
directory), point it at this repo, and describe the workspace. For example:

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

Claude clones this repo (for `template/`, plus `spec-model-per-repo/` if you chose the per-repo
model), then carries out the manual steps below against the paths you gave it.

### Manual steps

If you only have this repo's URL, first clone it — `git clone --depth 1 <url>` into a scratch
dir — so you have `template/` and `spec-model-per-repo/` to copy from. That clone is throwaway;
nothing in the finished workspace links back to it.

1. **Copy the template.** Copy `template/` to your workspace folder — conventionally
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
   - *Per-repo*: delete the workspace's `specs/`, then copy `spec-model-per-repo/README.md` and
     `_TEMPLATE.md` into each linked repo's own `specs/` (add a `specs/done/` too).
4. **Fill in placeholders.** Replace the `<...>` tokens in `CLAUDE.md`, `CONTEXT.md`,
   `README.md`, `.claude/settings.json`, and `.vscode/settings.json`, and delete the spec-model
   paragraph that doesn't apply in `CLAUDE.md` / `README.md`.

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
  scaffold, copied into each linked repo's `specs/` when you choose the per-repo model.

Replace every `<placeholder>` (e.g. `<workspace-name>`, `<repo>`, `<project / product name>`).
