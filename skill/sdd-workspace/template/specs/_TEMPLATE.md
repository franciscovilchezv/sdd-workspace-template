# Spec: <feature name>

> Context: see [../CONTEXT.md](../CONTEXT.md) for the domain and the relevant repo's `CLAUDE.md`
> for architecture and conventions. Don't re-explain the system — describe only what changes.
> Spans multiple linked repos? Name each affected repo's slice and mark one as the lead.

## Goal

<One or two sentences: what should be true after this is built, and for whom.>

## Background / motivation

<Why now? The problem this solves.>

## Behavior & acceptance criteria

<Concrete, checkable statements. Prefer observable behavior over implementation.>

- [ ]
- [ ]
- [ ]

<!-- OPTIONAL — keep this "## E2E coverage" section only if this workspace adopted the Playwright
     E2E module (e2e-playwright/); delete it otherwise. -->
## E2E coverage

<Which acceptance criteria are verified by a Playwright test at `e2e/<this-spec-slug>.spec.ts`
(same kebab-case slug as this file), and which are left to unit/component tests in the linked
repo. Cover the **browser-observable** criteria here; "None — unit-only" is valid for specs with
no browser-facing behavior (e.g. schema/logic-only work).

If the feature is role-specific, name the seeded **role(s)** the tests run as (from `e2e/support/roles.ts`);
omit if the default role is fine. Name a role, never an email or password.

A failing E2E test is fixed by changing the app **code** (usual case) or the **test** — never by
weakening this spec or an assertion to match a bug.>

## Changes

<Modules / routes / components / endpoints that change, grouped by repo if more than one.>

## Data / schema changes

<New tables/columns/migrations/config. "None" is valid.>

## Out of scope

<What this spec explicitly does NOT cover.>

## Open questions

<Anything undecided that needs an answer before or during implementation. The moment a question is
answered, delete it from here and fold the decision into the acceptance criteria / Changes — this
section lists only what is *still* open. An implementation agent reads everything here as unsettled,
so a resolved item left behind (worse, one whose stale wording contradicts the decision) will
mislead it. Don't recap answered questions or narrate what was decided — that's history the agent
never saw; when nothing is open, the section is just "None.">
