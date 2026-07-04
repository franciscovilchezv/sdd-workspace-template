---
name: sdd-workspace
description: >-
  Scaffold a Claude Code SDD workspace hub — a thin workspace folder that links one or more
  code repos via symlinks and drives them spec-first, without modifying those repos. Use when
  the user asks to set up, scaffold, create, or generate an SDD workspace, a spec-driven
  workspace, or a workspace hub that links repos. Bundles the template; no cloning needed.
---

# Create an SDD workspace

Scaffold a **workspace hub**: a thin folder that links one or more code repos via symlinks so
Claude Code and the editor see them together, while each repo keeps its own `.git`, deps, and
conventions. Features are written as **specs before implementation** and implemented against.
This skill bundles all scaffolding under its own directory — do **not** clone anything.

## Assets in this skill

Everything you copy from lives next to this file:

- `template/` — copied **wholesale** into the new workspace folder.
- `spec-model-per-repo/{README.md,_TEMPLATE.md}` — copied into each repo's `specs/` **only** if
  the per-repo spec model is chosen.
- `e2e-playwright/` — copied into the workspace **only** if a linked repo is a browser-facing web
  app and the user wants a workspace-level Playwright E2E suite. Follow its `README.md`.
- `at-mention-suggester/` — optional `@`-mention file suggester that reaches through the repo
  symlinks (the built-in picker can't). Copied into the workspace **only** if the user wants it
  and has `fd`. Follow its `README.md`.

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

## Steps

1. **Copy the template.** Copy the skill's `template/` (including dotfiles — `.claude/`,
   `.vscode/`, `.gitignore`) into the workspace folder, e.g.
   `<parent>/workspaces/<workspace-name>/`. Anywhere works as long as the symlinks will resolve.

2. **Symlink each repo.** From the workspace folder, create one symlink per repo, **named after
   the repo**, pointing at wherever the real repo actually lives. Compute each target for the
   **real** layout — do not assume `../../`:
   - Flat sibling two levels up (canonical): `ln -s ../../<repo> <repo>`
   - Nested in a subfolder: `ln -s ../../<group>/<nested-repo> <nested-repo>`
   - Elsewhere on disk: `ln -s /abs/path/to/<repo> <repo>`

   Then **verify**: `ls <repo>/` from the workspace must show that repo's files. A relative or
   absolute target is fine — the only test is that it resolves.

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

5. **Optional — add the `@`-mention suggester.** Only if the user wants `@<repo>/…` autocomplete
   into the linked repos (needs `fd`). Follow `at-mention-suggester/README.md`: copy
   `file-suggestion.sh` into the workspace `.claude/` (keep its executable bit), add the
   `fileSuggestion` block to `.claude/settings.json`, and paste its `CLAUDE.md` note in. The script
   is repo-agnostic — no placeholders. Skip entirely (copy nothing, add no `fileSuggestion` block)
   if not adopted.

6. **Fill in placeholders.** Replace every `<...>` token — `<workspace-name>`,
   `<project / product name>`, `<repo>`, `<one-line role>`, etc. — in `CLAUDE.md`, `CONTEXT.md`,
   `README.md`, `.claude/settings.json`, and `.vscode/settings.json` (and, if E2E was adopted,
   `playwright.config.ts`, `package.json`, `e2e/support/roles.ts`, `e2e/auth.setup.ts`). Fill the repo
   table in `CLAUDE.md` (one row per linked repo) and the layout diagram in `README.md` to match
   the **actual** paths. Read each linked repo (its `CLAUDE.md`, `README`, `package.json`/manifest)
   to fill roles, stack, and commands. **Leave blank any `<...>` you genuinely can't determine**
   and tell the user which ones need their input.

7. **Confirm.** Report the created path, the symlinks and that each resolves, the chosen spec
   model, whether E2E was added, whether the `@`-mention suggester was added, and any placeholders
   you left for the user.

## Invariants — keep these true

- **Symlink math.** Each symlink's target is whatever resolves to the real repo. In the
  canonical `<parent>/workspaces/<name>/` layout that's `../../<repo>`, but repos may sit at
  other depths, be nested, or live outside `<parent>` — compute per repo, never hardcode `../../`.
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
