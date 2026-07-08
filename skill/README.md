# `sdd-workspace` skill

A self-contained Claude Code skill that scaffolds an SDD workspace hub (the same thing this
repo's root `README.md` describes doing by hand). It **bundles** `template/`,
`spec-model-per-repo/`, and the optional `e2e-playwright/`, `at-mention-suggester/`, and
`update-from-template/` modules, so once installed it needs no network and no clone.

## Install

Pick a scope and copy `sdd-workspace/` into a `skills/` directory:

```bash
# Personal — available in every project on this machine
cp -R sdd-workspace ~/.claude/skills/sdd-workspace

# Project — available to anyone working in that repo/workspace (commit it)
cp -R sdd-workspace /path/to/your/workspaces-repo/.claude/skills/sdd-workspace
```

`~/.claude/skills/` is the usual choice if you spin up workspaces from wherever your
`workspaces/` folders live.

## Use

In a Claude Code session, just describe the workspace — the skill triggers on intent:

> Set up an SDD workspace named `checkout-flow` linking `/Users/me/git/api-service` and
> `/Users/me/git/web-app`, per-repo spec model.

Claude runs the bundled procedure (`sdd-workspace/SKILL.md`): copy template → grant each repo by
its real path (in `additionalDirectories` + the `.code-workspace`, no symlinks) → pick spec model
→ fill placeholders.

## Where the scaffolding lives

The `template/`, `spec-model-per-repo/`, `e2e-playwright/`, `at-mention-suggester/`, and
`update-from-template/` trees under `sdd-workspace/` are the **single source of truth** — there's
no second copy at the repo root. Edit them here directly; the repo's root `README.md` and
`CLAUDE.md` point at these paths.
