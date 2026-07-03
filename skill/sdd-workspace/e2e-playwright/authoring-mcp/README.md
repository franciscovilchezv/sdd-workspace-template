# Authoring loop — Playwright MCP (`init-agents`)

One of two interchangeable authoring loops for the E2E module (the other is `../authoring-cli/`).
This one drives test authoring through the **Playwright MCP** and the three `init-agents`
subagents — a structured-tool loop. Pick **either** this or the CLI, not both.

## Files here

| File | Role |
|---|---|
| `package.json` | The MCP-flavored suite package (`@playwright/test`, `dotenv`, `test:e2e*` scripts). |
| `.mcp.json` | Registers the `playwright-test` MCP server the agents use. |
| `.claude/agents/playwright-test-{planner,generator,healer}.md` | The `init-agents` agents, **pre-modified** for this layout (see below). |

## Adoption

From the workspace folder, after copying the shared files (`../playwright.config.ts`,
`../.env.e2e.example`, `../e2e/`, `../gitignore-additions.txt` — see `../README.md`):

1. Copy this directory's `package.json`, `.mcp.json`, and `.claude/agents/` into the workspace
   root (merge `.claude/agents/` into any existing `.claude/`).
2. Install: `npm install` (or bun/pnpm) then `npx playwright install`.
3. Use the pre-modified agents as-is. (Re-running `init-agents` is optional — see below.)

## The agents and their modifications

`@playwright/test` (≥ the version that ships `init-agents`, e.g. `1.61.1`) can scaffold three
editable agents:

```bash
npx playwright init-agents --loop=claude   # run from the workspace root
```

That command generates `.claude/agents/playwright-test-{planner,generator,healer}.md`, `.mcp.json`,
and a `seed.spec.ts`, and — only if absent — a `specs/` dir with a README (its
`if (!existsSync("specs"))` guard means it **won't overwrite** the workspace's SDD `specs/`).

**Why this module ships the agents pre-modified.** Two "specs" would otherwise collide: the SDD
`specs/` (hand-authored feature intent — the source of truth) and Playwright's generated "specs"
(derived test plans). We keep the **source** side (`specs/`) plain and prominent and namespace the
**derived/tooling** side under `e2e/`. So the shipped agents here are the stock `init-agents`
output with these edits already applied:

| Agent | Modification |
|---|---|
| **planner** | Saves plans to `e2e/specs/<slug>.plan.md` (same kebab slug as the SDD spec), **never** to the top-level SDD `specs/`. Routes generated tests to `e2e/<slug>/…`, or `e2e/authed/<slug>/…` for signed-in features, naming the seeded role from `e2e/roles.ts`. Seed file is `e2e/seed.spec.ts`. |
| **generator** | Example paths point at `e2e/specs/` + `e2e/seed.spec.ts` (the `e2e/`-namespaced layout). |
| **healer** | Added a **triage guardrail**: it may fix locators/timing only. It must **not** weaken/delete an assertion to match buggy app behavior — a real product bug is left asserted, marked `test.fixme()` with a note, and surfaced for a human. |

The output paths (`specs/…`) in stock agents are only scaffold-dir names and example paths — the
planner actually writes via the `planner_save_plan` MCP tool whose filename is a free argument
relative to the workspace root, so redirecting output is purely editing those example paths. Use
the pre-modified files here **instead of** re-running `init-agents`; or, if you re-run it against a
newer Playwright, re-apply the table above to the regenerated files. Also exclude the planner's
`e2e/seed.spec.ts` from the runnable `chromium` project — the shared config already does
(`testIgnore: [/seed\.spec\.ts/]`).

### Generated-artifact layout

| Artifact | Location |
|---|---|
| SDD feature specs (source of truth) | `specs/<slug>.md` — **unchanged** |
| Playwright test **plans** (generated) | `e2e/specs/<slug>.plan.md` |
| Playwright **tests** (generated) | `e2e/<slug>/*.spec.ts` (or `e2e/authed/<slug>/…`) |
| Planner **seed** | `e2e/seed.spec.ts` |

Flow: an SDD spec (`specs/<slug>.md`) is the **planner's** input → plan at `e2e/specs/<slug>.plan.md`
→ **generator** produces `e2e/<slug>/*.spec.ts` with selectors verified against the live app →
**healer** patches test-level failures (within the triage boundary).
