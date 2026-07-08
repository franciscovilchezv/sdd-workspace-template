---
name: update-from-template
description: >-
  Pull later changes from the sdd-workspace-template into THIS workspace without clobbering its
  customizations. Use when the user asks to update, sync, refresh, or pull template changes into
  the workspace — reconciles the workspace docs (and any adopted optional modules) against the
  latest template by intent, preserving filled placeholders, the chosen spec model, and adopted/
  deleted optional blocks. Runs inside a generated SDD workspace.
---

# Update this workspace from the template

This workspace was scaffolded from **sdd-workspace-template**
(`https://github.com/franciscovilchezv/sdd-workspace-template`). That template keeps evolving —
new spec conventions, doc fixes, module updates. This skill pulls those changes **into this
workspace** while preserving everything that makes this a workspace rather than a pristine
template copy.

## The core idea: reconcile, don't copy

A generated workspace is a **customized fork** of the template's `template/` tree. You must **not**
re-copy template files over the workspace — that would undo the workspace's customizations. Instead
do a **semantic 3-way reconcile** per file:

- **base** — the template as it was when this workspace was generated (the recorded
  `.template-version`).
- **upstream** — the template now (latest on the default branch).
- **mine** — this workspace's current, customized file.

Apply the *intent* of each `upstream` change (what changed between `base` and `upstream`) on top of
`mine`, keeping `mine`'s customizations. If `.template-version` is missing or its ref can't be
fetched, fall back to a **2-way reconcile** (compare `upstream` to `mine` and apply changes that
are clearly template-wording updates, not this workspace's own content) — and say so in the report.

## Never do these (customization-preserving invariants)

- **Never re-introduce a deleted spec-model paragraph.** The workspace kept exactly one of MODEL A
  (workspace-level) / MODEL B (per-repo). If an upstream change edits *both*, apply it only to the
  one this workspace has; never re-add the deleted one.
- **Never overwrite a filled placeholder with a `<...>` token.** The workspace's `<workspace-name>`,
  `<path-to-repo>`, repo table, layout diagram, roles, and stack are real values now — keep them.
- **Never touch an optional module the workspace didn't adopt.** Only reconcile E2E files if an
  `e2e/` suite exists here, and the `@`-mention suggester only if `.claude/file-suggestion.sh`
  exists here. Don't add a module the workspace opted out of.
- **Never touch the workspace's own content** — specs under `specs/` (or `specs/done/`), granted
  paths in `.claude/settings.json` and the `.code-workspace`, or `.vscode/` settings.
- **Preserve which E2E authoring loop was chosen** (MCP vs. CLI) — reconcile only the loop this
  workspace has; don't cross-add the other loop's files or doc lines.

## Steps

1. **Confirm you're in a workspace.** The current dir should have a `CLAUDE.md` describing an SDD
   workspace and a `.claude/settings.json` with `permissions.additionalDirectories`. If not, stop
   and tell the user to run this from the workspace root.

2. **Read the base version.** Read `.template-version` at the workspace root. Keep its value as
   `BASE_REF`. If the file is missing, note you'll do a 2-way reconcile.

3. **Clone upstream** to a scratch dir (throwaway):
   ```bash
   git clone --depth 50 https://github.com/franciscovilchezv/sdd-workspace-template <scratch>
   ```
   `upstream` = `<scratch>/skill/sdd-workspace/`. Read `<scratch>/skill/sdd-workspace/VERSION` as
   the new version string. If `BASE_REF` is a resolvable commit, get the `base` tree from it
   (`git -C <scratch> show <BASE_REF>:skill/sdd-workspace/...`, deepening the clone if needed); if
   it won't resolve, drop to 2-way and say so.

4. **Detect what this workspace adopted**, so you only reconcile relevant files:
   - **Spec model** — workspace-level if a `specs/` dir exists here; per-repo if not (specs live in
     each linked repo's `specs/`, read from `additionalDirectories`).
   - **E2E** — adopted if `playwright.config.ts` / `e2e/` exists here; note the loop (`.mcp.json` +
     `.claude/agents/` = MCP; `.claude/skills/playwright-cli/` = CLI).
   - **`@`-mention suggester** — adopted if `.claude/file-suggestion.sh` exists here.

5. **Reconcile the docs.** For each of `CLAUDE.md`, `CONTEXT.md`, `README.md`, and the spec
   `README.md` / `_TEMPLATE.md` (workspace-level here, or per-repo in each linked repo), compute
   what changed `base`→`upstream` and apply that intent to `mine`, honoring every invariant above.
   Skip optional blocks for modules this workspace didn't adopt. The `at-mention-suggester` and
   `e2e-playwright` module files reconcile only if adopted.

6. **Reconcile adopted optional modules** — for E2E, bring forward changes to the shared runner
   (`playwright.config.ts`, `e2e/` harness) and the adopted loop's files, keeping filled
   placeholders. For the `@`-mention suggester, `.claude/file-suggestion.sh` is repo-agnostic and
   copied verbatim — if it changed upstream, replace it wholesale.

7. **Refresh this skill** — if `update-from-template/workspace-skill/SKILL.md` changed upstream,
   update `.claude/skills/update-from-template/SKILL.md` here too.

8. **Bump the version** — write the new version string from step 3 into `.template-version`.

9. **Report** — list, per file: what you applied, what you deliberately skipped as an
   already-made customization, and anything genuinely ambiguous that needs the user's decision.
   Remind the user this was a judgment-based reconcile — **review the diff before committing.**

## If nothing changed

If `BASE_REF` already equals the upstream version, say the workspace is up to date and stop —
don't rewrite files.
