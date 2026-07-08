---
name: sdd-workspace
description: >-
  Scaffold a Claude Code SDD workspace hub — a thin workspace folder that references one or more
  code repos by their real path (granted via additionalDirectories, no symlinks) and drives them
  spec-first, without modifying those repos. Use when the user asks to set up, scaffold, create,
  or generate an SDD workspace, a spec-driven workspace, or a workspace hub that links repos.
  Bundles the template; no cloning needed.
---

# Create an SDD workspace

Scaffold a **workspace hub**: a thin folder that references one or more code repos by their real
path — granted to Claude Code via `permissions.additionalDirectories` and listed in a VS Code
`.code-workspace` (no symlinks) — so Claude Code and the editor see them together, while each repo
keeps its own `.git`, deps, and conventions. Features are written as **specs before
implementation** and implemented against. This skill bundles all scaffolding under its own
directory — do **not** clone anything.

## Assets in this skill

Everything you copy from lives next to this file:

- `template/` — copied **wholesale** into the new workspace folder.
- `spec-model-per-repo/{README.md,_TEMPLATE.md}` — copied into each repo's `specs/` **only** if
  the per-repo spec model is chosen.
- `e2e-playwright/` — copied into the workspace **only** if a linked repo is a browser-facing web
  app and the user wants a workspace-level Playwright E2E suite. Follow its `README.md`.
- `at-mention-suggester/` — optional `@`-mention file suggester that reads
  `additionalDirectories` and autocompletes files in the granted repos (the built-in picker only
  walks the workspace root). Copied into the workspace **only** if the user wants it and has `fd`.
  Follow its `README.md`.
- `update-from-template/` — optional skill installed into the workspace's `.claude/skills/` so it
  can later pull template changes **without clobbering its customizations** (a semantic reconcile,
  not a re-copy). Copied into the workspace **only** if the user wants it to track template
  updates. Follow its `README.md`.
- `VERSION` — the template's version anchor, recorded into the workspace as `.template-version`
  when the `update-from-template/` module is adopted (the reconcile's base ref).

Refer to them by absolute path. The skill root is the directory containing this `SKILL.md`;
build paths from there (e.g. `"$SKILL_DIR/template"`), don't assume the current working
directory.

## What you need from the user

Before scaffolding, make sure you have (ask only for what's missing):

1. **Workspace name** — e.g. `checkout-flow`.
2. **Where the workspace folder should live** — usually a `workspaces/` directory. If Claude
   was opened there, that's the default.
3. **Which repos to link** — an absolute path (or resolvable relative path) per repo.
4. **Spec model** — *workspace-level* (default) or *per-repo*. If unstated, default to
   workspace-level and say so.
5. **Product / project name** — for placeholders; infer from the repos if you can.
6. **E2E?** — whether to add a workspace-level Playwright E2E suite. Only relevant if a linked
   repo is a browser-facing web app. If unstated, default to **no** and mention it's available.
   If yes, also ask the **authoring loop**: Playwright **MCP** (`init-agents` subagents) or the
   Playwright **agent CLI** (`@playwright/cli` + skills). If unstated, default to the CLI loop and
   say so.
7. **`@`-mention suggester?** — whether to add the optional `at-mention-suggester/` module so
   `@<repo>/…` autocompletes into the linked repos. Needs `fd` on `PATH`. If unstated, default to
   **no** and mention it's available (offer it if `fd` is installed).
8. **Track template updates?** — whether to install the optional `update-from-template/` skill so
   the workspace can later pull template changes via a customization-preserving reconcile. If
   unstated, default to **no** and mention it's available.

## Steps

1. **Copy the template.** Copy the skill's `template/` (including dotfiles — `.claude/`,
   `.vscode/`, `.gitignore`, and `<workspace-name>.code-workspace`) into the workspace folder,
   e.g. `<parent>/workspaces/<workspace-name>/`. Anywhere works as long as the granted paths will
   resolve.

2. **Grant each repo by its real path.** No symlinks. For each repo, work out the path that
   resolves to it **from the workspace folder** — compute it for the **real** layout, do not
   assume `../../`:
   - Flat sibling two levels up (canonical): `../../<repo>`
   - Nested in a subfolder: `../../<group>/<nested-repo>`
   - Elsewhere on disk: an absolute path like `/abs/path/to/<repo>`

   Then wire that path into **both** places:
   - **`.claude/settings.json`** → add it to `permissions.additionalDirectories` (this is what
     grants Claude Code file access to the repo).
   - **`<workspace-name>.code-workspace`** → add a `{ "name": "<repo>", "path": "<path>" }` entry
     under `folders` (so VS Code shows it in the multi-root view).

   Then **verify** each path resolves: `ls <path>/` from the workspace must show that repo's files.
   A relative (any depth) or absolute path is fine — the only test is that it resolves.

3. **Pick the spec model.**
   - **Workspace-level** (default): keep the workspace's `specs/` directory as-is. In
     `CLAUDE.md` keep the MODEL A paragraph and delete MODEL B; in `README.md` keep the
     workspace-level bullet's intent.
   - **Per-repo**: **delete** the workspace's `specs/` directory, then into **each** linked
     repo's own `specs/` copy `spec-model-per-repo/README.md` and `spec-model-per-repo/_TEMPLATE.md`
     and add an empty `specs/done/`. In `CLAUDE.md` keep MODEL B and delete MODEL A.

4. **Optional — add E2E.** Only if the user wants a workspace-level Playwright E2E suite (a
   linked repo serves a web UI). Follow `e2e-playwright/README.md`. Copy the **shared** files —
   `playwright.config.ts`, `.env.e2e.example`, `e2e/`, and `gitignore-additions.txt` (append to
   the workspace `.gitignore`) — then the **chosen authoring loop** from its subdir:
   - **MCP** (`e2e-playwright/authoring-mcp/`): copy its `package.json`, `.mcp.json`, and
     `.claude/agents/` in. Agents are pre-modified; don't re-run `init-agents` unless upgrading.
   - **Agent CLI** (`e2e-playwright/authoring-cli/`): copy its `package.json` in, then run
     `npx playwright-cli install --skills` at the workspace root and commit the resulting
     `.claude/skills/playwright-cli/`. No subagents.

   Set `<app-repo>` / `<dev-server-cmd>` in the config and `<workspace-name>` in `package.json`.
   **Keep** the optional E2E blocks in `CLAUDE.md`, `README.md`, `CONTEXT.md`, `specs/README.md`,
   and `specs/_TEMPLATE.md`, and in `CLAUDE.md` keep only the authoring-loop line for the loop you
   picked. If E2E is **not** adopted, **delete** those *delete-if-unused* E2E blocks from the five
   files so no stray E2E instructions ship.

5. **Optional — add the `@`-mention suggester.** Only if the user wants `@../../<repo>/…`
   autocomplete into the granted repos (needs `fd`; `jq` to read the setting). The built-in picker
   only walks the workspace root, so it ignores `additionalDirectories`. Follow
   `at-mention-suggester/README.md`: copy `file-suggestion.sh` into the workspace `.claude/` (keep
   its executable bit), add the `fileSuggestion` block to `.claude/settings.json`, and paste its
   `CLAUDE.md` note in. The script is repo-agnostic — it reads the repos from
   `additionalDirectories`, no placeholders. Skip entirely (copy nothing, add no `fileSuggestion`
   block) if not adopted.

6. **Optional — install the update-from-template skill.** Only if the workspace should be able to
   later pull template changes. Follow `update-from-template/README.md`: copy
   `update-from-template/workspace-skill/SKILL.md` into `.claude/skills/update-from-template/`, and
   write a `.template-version` file at the workspace root recording the base ref — the clone's
   `git rev-parse HEAD` if you scaffolded from a clone, else this skill's `VERSION` string. Skip
   entirely (copy nothing, write no `.template-version`) if not adopted.

7. **Fill in placeholders + rename the code-workspace.** Replace every `<...>` token —
   `<workspace-name>`, `<project / product name>`, `<repo>`, `<path-to-repo>`, `<one-line role>`,
   etc. — in `CLAUDE.md`, `CONTEXT.md`, `README.md`, `.claude/settings.json`,
   `.vscode/settings.json`, and `<workspace-name>.code-workspace` (and, if E2E was adopted,
   `playwright.config.ts`, `package.json`, `e2e/support/roles.ts`, `e2e/auth.setup.ts`). **Rename**
   `<workspace-name>.code-workspace` to the real workspace name (e.g. `checkout-flow.code-workspace`).
   Fill the repo table in `CLAUDE.md` (one row per linked repo, Path = its real granted path) and
   the layout diagram in `README.md` to match the **actual** paths. Make sure each repo's real path
   appears consistently in `.claude/settings.json` (`additionalDirectories`) and the
   `.code-workspace` folders. Read each linked repo (its `CLAUDE.md`, `README`,
   `package.json`/manifest) to fill roles, stack, and commands. **Leave blank any `<...>` you
   genuinely can't determine** and tell the user which ones need their input.

8. **Confirm.** Report the created path, each repo's granted path and that it resolves (`ls <path>/`),
   the chosen spec model, whether E2E was added, whether the `@`-mention suggester was added,
   whether the update-from-template skill was installed, and any placeholders you left for the user.

## Invariants — keep these true

- **Path math.** Each repo is granted by whatever path resolves to it from the workspace folder.
  In the canonical `<parent>/workspaces/<name>/` layout that's `../../<repo>`, but repos may sit at
  other depths, be nested, or live outside `<parent>` — compute per repo, never hardcode `../../`.
- **Grant is two places, kept in sync.** A repo's real path appears in **both**
  `permissions.additionalDirectories` (Claude Code's file-access grant) and the `.code-workspace`
  `folders` (VS Code's multi-root view). Add/remove/rename a repo in both. No symlinks are created.
- **One spec model, consistently.** The workspace ends up describing exactly one model. Don't
  leave both MODEL A and MODEL B paragraphs, and don't leave a `specs/` dir in a per-repo
  workspace.
- **Placeholders get filled, not shipped blank.** The `<...>` tokens ship blank in the template
  on purpose; in a *generated* workspace they should be replaced (or explicitly flagged back to
  the user), never left as literal `<...>` silently.
- **E2E is all-or-nothing.** Either adopt the `e2e-playwright/` module *and* keep the optional
  E2E blocks in the workspace docs, or adopt neither — never leave the E2E doc blocks in a
  workspace that has no `e2e/` suite, and never copy the harness without wiring the docs.
- **Exactly one authoring loop.** If E2E is adopted, copy the MCP loop **or** the CLI loop, not
  both, and keep only that loop's authoring-loop line in `CLAUDE.md`. Don't leave `.mcp.json` +
  `.claude/agents/` in a CLI workspace, or `.claude/skills/playwright-cli/` in an MCP one.
- **`@`-mention suggester is all-or-nothing.** If adopted, the workspace has all three of
  `.claude/file-suggestion.sh`, the `fileSuggestion` block in `.claude/settings.json`, and the
  `CLAUDE.md` note. Never ship a `fileSuggestion` block pointing at a script that wasn't copied,
  and never copy the script without wiring the setting. If not adopted, none of the three exist.
- **update-from-template is all-or-nothing.** If adopted, the workspace has **both**
  `.claude/skills/update-from-template/SKILL.md` and a `.template-version` file at its root. Never
  install the skill without recording `.template-version` (it has no base to reconcile against),
  and never leave a `.template-version` with no skill. If not adopted, neither exists.
