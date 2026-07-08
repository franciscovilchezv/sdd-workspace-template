# Optional module: update-from-template skill

A skill **installed into a generated workspace** (at `.claude/skills/update-from-template/`) that
pulls later changes from this template — `https://github.com/franciscovilchezv/sdd-workspace-template`
— into the workspace **without clobbering the workspace's customizations**.

## Why

A generated workspace is a **customized fork** of `template/`, not a live copy. By the time it
exists, its `<...>` placeholders are filled, one spec model was chosen (the other paragraph
deleted), the optional E2E and `@`-mention blocks were kept-or-deleted, and
`<workspace-name>.code-workspace` was renamed. So when the template later changes — e.g. a new
spec convention lands in `template/CLAUDE.md` — you **cannot** just re-copy the file: that would
undo every one of those decisions, and try to re-add the spec-model paragraph the workspace
deliberately deleted.

What you actually want is a **semantic 3-way reconcile**: given the template as it was when the
workspace was born (**base**), the template now (**upstream**), and this workspace's customized
copy (**mine**), apply the *intent* of upstream's changes on top of `mine` while preserving the
workspace's customizations. That's a poor fit for `patch`/`git merge` (the files diverged
structurally) and a good fit for a skill — Claude reads all three and merges by meaning. This
module is that skill.

It is **opt-in** and ships **outside** `template/` (like `e2e-playwright/` and
`at-mention-suggester/`) so the default workspace doesn't carry it. Adopt it if the workspace
should be able to track template updates; skip it for a one-off workspace that will never re-sync.

## What it reconciles

- **Docs** — `CLAUDE.md`, `CONTEXT.md`, `README.md`, and the spec `README.md` / `_TEMPLATE.md`
  (workspace-level or, under the per-repo model, each linked repo's copies).
- **Adopted optional modules** — only the ones the workspace actually took: the `e2e-playwright/`
  runner/authoring-loop files if an `e2e/` suite is present, and `.claude/file-suggestion.sh` if
  the `@`-mention suggester was adopted. Modules the workspace never adopted are left alone.

It never touches the workspace's own content — filled placeholders, the repo table, the layout
diagram, the granted paths in `.claude/settings.json` and the `.code-workspace`, or specs under
`specs/` (or `specs/done/`).

## The base version (`.template-version`)

The reconcile needs to know **which template revision this workspace was generated from** so it
can tell an upstream *change* from a workspace *customization*. Instantiation records that as a
`.template-version` file at the workspace root (see the parent `SKILL.md`, install step):

- If the scaffolding came from a **clone** of this repo, record the clone's `git rev-parse HEAD`
  (a real ref → enables a true 3-way merge).
- If it came from the **installed skill** (no git metadata), record the skill's `VERSION` string.

The skill fetches the recorded ref from the remote to use as the merge **base**. If the ref can't
be resolved (e.g. a `VERSION` string that was never tagged upstream), it **degrades gracefully to
a 2-way reconcile** (upstream-now vs. mine) — still useful, just noisier, since it can't be sure
which differences are intentional customizations. Tagging releases in this repo to match `VERSION`
lets skill-installed workspaces get 3-way merges too.

## Dependencies

- **`git`** — required, to clone the upstream template into a scratch dir.
- Network access to `github.com`.

## Adopt (during instantiation)

From the workspace root, after the workspace is otherwise set up:

1. **Copy the skill** into the workspace:
   ```bash
   mkdir -p .claude/skills/update-from-template
   cp <this-module>/workspace-skill/SKILL.md .claude/skills/update-from-template/SKILL.md
   ```
2. **Record the base version** as `.template-version` at the workspace root — the clone's
   `git rev-parse HEAD` if you scaffolded from a clone, else the skill's `VERSION` string.
3. **Tell the user** it's available: from inside the workspace, ask Claude to *"update this
   workspace from the template"* (or run the `update-from-template` skill) to pull later changes.

If not adopted, copy nothing and write no `.template-version` — none of the three exist.

## Use (inside a generated workspace)

Ask Claude, in a session opened in the workspace: **"Update this workspace from the template."**
The skill clones upstream, reconciles the docs (and any adopted optional modules) into the
workspace preserving its customizations, bumps `.template-version`, and reports exactly what it
changed, what it skipped as already-customized, and anything that needs a human decision. Review
the diff before committing — a reconcile is a judgment call, not a mechanical merge.
