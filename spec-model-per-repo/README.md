# specs/ — <repo>

Spec-driven development for this repo. A **spec** describes intended behavior *before*
it's built and is the source of truth that drives implementation. Specs here are
**versioned with this repo** and self-contained — they reference [`../CLAUDE.md`](../CLAUDE.md)
for architecture, not any workspace-level file (so they stay valid for anyone who clones
just this repo).

> This is the **per-repo** spec model: each linked repo owns its `specs/`. The workspace's
> `README.md` explains the alternative **workspace-level** model. Pick one per workspace.

## Workflow

1. Copy the template:
   ```bash
   cp specs/_TEMPLATE.md specs/<short-feature-name>.md
   ```
2. Fill it in (Goal, acceptance criteria, changes in this repo, schema changes, out of scope).
3. Implement against it:
   ```
   implement @specs/<short-feature-name>.md
   ```
4. Once it's fully implemented, move it to `specs/done/`:
   ```bash
   mv specs/<short-feature-name>.md specs/done/
   ```

## Cross-repo features

A feature that spans multiple linked repos gets a **companion spec in each affected repo**,
each describing that repo's slice. Cross-link them by repo name and mark one as the **lead**
spec that lists the others. Keep each repo's spec implementable on its own.

## Conventions

- One file per feature, kebab-case (e.g. `add-feature-name.md`).
- `_TEMPLATE.md` is the skeleton — copy it, don't implement it.
- Keep acceptance criteria observable and checkable.
- When an open question gets answered, move it **out** of the **Open questions** section —
  fold the decision into the acceptance criteria / changes (or note it inline). Keep
  **Open questions** listing only what's still undecided.
- Once a spec is fully implemented, **move it to `specs/done/`** (`mv specs/<name>.md specs/done/`).
  `specs/` then lists only what's still in flight; `specs/done/` is the shipped record.
