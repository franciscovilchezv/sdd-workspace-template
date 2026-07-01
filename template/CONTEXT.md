# CONTEXT.md

Stable domain context for the **<workspace-name>** workspace. This is the shared "why" that
every spec in `specs/` builds on — the product, the architecture, and the vocabulary. It
changes rarely. Behavioral rules and commands live in `CLAUDE.md` (workspace root) and, in
full detail, in each linked repo's own `CLAUDE.md`.

## What this workspace is

<One paragraph: what the product/system is, who it's for, and which repos collaborate to
deliver it. Name each linked repo and its role.>

## Architecture at a glance

> The authoritative, detailed architecture is in each repo's `CLAUDE.md`. This is the
> orientation summary specs can lean on.

- **<area, e.g. Frontend>** — <stack / key choices>
- **<area, e.g. Backend>** — <stack / key choices>
- **<area, e.g. Runtime / tooling>** — <stack / key choices>

## Common commands (run inside the relevant repo)

- `<cmd>` — <what it does>
- `<cmd>` — <what it does>

See each repo's `CLAUDE.md` for the full command list.

## Glossary

- **<term>** — <definition>
- **<term>** — <definition>
- **spec** — a description of intended behavior that drives implementation, written before
  the code. Lives either in this workspace's `specs/` or in each linked repo's own `specs/`,
  depending on the spec model this workspace chose (see `CLAUDE.md`).
