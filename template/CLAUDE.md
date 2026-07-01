# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this workspace.

## Workspace Overview

This is the **<workspace-name>** workspace — a Claude Code hub for working on
**<project / product name>**.

It links one or more git repositories via symlinks. Each repo has its own `.git`, dependencies,
`.env`, and its own `CLAUDE.md` with detailed architecture notes — **read the repo's `CLAUDE.md`
before working in it.**

| Symlink | Repo | Role | Details |
|---|---|---|---|
| `<repo>/` | `../../<repo>` | <one-line role> | `<repo>/CLAUDE.md` |
<!-- add a row per linked repo -->

Always `cd` into the relevant repo directory before running commands.

## Domain context

The product domain and the high-level shape of the system live in `CONTEXT.md` (workspace
root) and, in much more detail, in each repo's `CLAUDE.md`. `CONTEXT.md` is **not**
auto-loaded — read it for any domain-heavy task or when implementing a spec. This file holds
workspace rules.

## Spec-driven development

Feature work is described as a spec before implementation. This workspace uses **one** of two
spec models — **keep the matching paragraph below and delete the other:**

<!-- MODEL A — workspace-level specs -->
**Specs live at the workspace level**, in this workspace's own `specs/` directory —
deliberately **not** inside the linked repo(s). The linked repos have their own teams and
conventions, and we don't want to add a `specs/` workflow to them. Keeping specs here lets us
drive implementation spec-first without changing how those repos' developers work. Copy
`specs/_TEMPLATE.md`, fill it in, and implement against it. See `specs/README.md`.

<!-- MODEL B — per-repo specs (delete MODEL A above and the workspace-level specs/ dir) -->
**Specs live per-repo**, in each linked repo's own `specs/` directory (versioned with that
repo) — not at the workspace level. A feature that spans multiple repos gets a companion spec
in each affected repo, cross-linked, with one marked as the lead. Copy that repo's
`specs/_TEMPLATE.md`, fill it in, and implement against it. See each repo's `specs/README.md`.
