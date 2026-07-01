# specs/ — <workspace-name> workspace

Spec-driven development for the work done in this workspace. A **spec** describes intended
behavior *before* it's built and is the source of truth that drives implementation.

These specs live at the **workspace level**, deliberately **not** inside the linked repo(s).
Those repos have their own teams, conventions, and tooling; we drive our work spec-first
without adding a `specs/` workflow to them. Specs reference workspace docs
([`../CONTEXT.md`](../CONTEXT.md)) and each repo's own `CLAUDE.md` for architecture.

> This is the **workspace-level** spec model. If instead this workspace uses the **per-repo**
> model (specs versioned inside each linked repo), delete this `specs/` directory — the spec
> workflow then lives in each repo's own `specs/README.md`. See the workspace `README.md`.

## Workflow

1. Copy the template:
   ```bash
   cp specs/_TEMPLATE.md specs/<short-feature-name>.md
   ```
2. Fill it in (Goal, acceptance criteria, changes, schema changes, out of scope).
3. Implement against it:
   ```
   implement @specs/<short-feature-name>.md
   ```
4. Once it's fully implemented, move it to `specs/done/`:
   ```bash
   mv specs/<short-feature-name>.md specs/done/
   ```

## Conventions

- One file per feature, kebab-case (e.g. `add-feature-name.md`).
- `_TEMPLATE.md` is the skeleton — copy it, don't implement it.
- Keep acceptance criteria observable and checkable.
- Reference architecture from each repo's `CLAUDE.md`; don't re-explain the system in the spec.
- When an open question gets answered, move it **out** of the **Open questions** section —
  fold the decision into the acceptance criteria / changes (or note it inline). Keep
  **Open questions** listing only what's still undecided.
- Once a spec is fully implemented, **move it to `specs/done/`** (`mv specs/<name>.md specs/done/`).
  `specs/` then lists only what's still in flight; `specs/done/` is the shipped record.
