# `sdd-workspace` skill

A self-contained Claude Code skill that scaffolds an SDD workspace hub (the same thing this
repo's root `README.md` describes doing by hand). It **bundles** `template/` and
`spec-model-per-repo/`, so once installed it needs no network and no clone.

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

Claude runs the bundled procedure (`sdd-workspace/SKILL.md`): copy template → symlink repos →
pick spec model → fill placeholders.

## Keeping it in sync

The `template/` and `spec-model-per-repo/` trees here are **copies** of the ones at the repo
root (required so the skill is portable). If you change the canonical trees at the repo root,
re-copy them into `sdd-workspace/` (or vice-versa) so the two stay aligned.
