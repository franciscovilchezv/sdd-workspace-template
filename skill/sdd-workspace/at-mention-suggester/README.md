# Optional module: `@`-mention file suggester

A drop-in script that makes `@../../<repo>/…` autocomplete into the repos this workspace grants
via `permissions.additionalDirectories`.

## Why

A workspace references its repos by their real path, granted through
`permissions.additionalDirectories` in `.claude/settings.json` (no symlink). Claude Code's
built-in `@` picker walks the filesystem **only from the workspace root** — it has no awareness of
`additionalDirectories` — so `@../../<repo>/…` completes nothing, and the granted repos' files are
unreachable via `@`-mentions.

This module replaces the picker with a small script wired in through Claude Code's `fileSuggestion`
setting. The script reads `permissions.additionalDirectories` at query time and, for each granted
directory, emits candidates prefixed with **exactly the path you'd type** (e.g.
`../../<repo>/src/foo.ts`) — **folders** (with a trailing `/`) and **files**, plus each granted
directory's own root (e.g. `../../<repo>/`) and `./` for the workspace itself, so any of them can be
`@`-tagged. It is **repo-agnostic** — everything comes from `additionalDirectories`, so it needs no
per-repo configuration and no placeholder filling. Change an entry in `additionalDirectories` and
what autocompletes changes on the next keystroke, no script edit.

An empty `@` query still lists **workspace-root** candidates only — the granted repos aren't
force-injected into the default list (that would flood it with a large sibling repo's tree). They
appear once you start typing a path that could match them.

This is **opt-in** (unlike the rest of `template/`, which is copied wholesale) because it needs
`fd` on `PATH`. Skip it if you don't have `fd` or don't want a custom picker.

## Dependencies

- **`fd`** — required (https://github.com/sharkdp/fd). The walk uses `fd`; without it the
  script fails. Install: `brew install fd` / `apt install fd-find` / `cargo install fd-find`.
- **`jq`** — required to read `additionalDirectories` from settings. Without it the script still
  works but degrades to **workspace-root only** (the granted repos won't autocomplete). Install:
  `brew install jq` / `apt install jq`.
- **`fzf`** — optional; enables proper fuzzy ranking (best matches first). Without it the script
  falls back to a regex matcher.

## Adopt

From the workspace root:

1. **Copy the script**, keeping its executable bit:
   ```bash
   cp <this-module>/file-suggestion.sh .claude/file-suggestion.sh
   chmod +x .claude/file-suggestion.sh
   ```
2. **Wire it into `.claude/settings.json`** — add the `fileSuggestion` block at the top level
   (sibling of `permissions`):
   ```json
   "fileSuggestion": {
     "type": "command",
     "command": ".claude/file-suggestion.sh"
   }
   ```
   The script reads the repos from `permissions.additionalDirectories` in the same file, so make
   sure each repo you want to autocomplete is listed there (it already is if you granted it access).
3. **Document it in the workspace `CLAUDE.md`** — paste this under a heading near the top so
   Claude knows the picker is customized:
   ```markdown
   ## `@`-mention file suggestions across the granted repos

   The linked repos are granted by their real path via `permissions.additionalDirectories` in
   `.claude/settings.json`, and Claude Code's built-in `@` picker only walks the workspace root —
   so `@../../<repo>/…` wouldn't autocomplete on its own. `.claude/file-suggestion.sh` (wired in
   via the `fileSuggestion` setting) replaces the picker with a walk that also covers every
   `additionalDirectories` entry, emitting candidates prefixed with the exact path you'd type.
   It's repo-agnostic — no per-repo config; it follows whatever `additionalDirectories` lists.
   **Requires `fd`** on `PATH` (`jq` to read the setting; `fzf` optional, for ranking).
   ```
4. **Restart Claude Code** — the `fileSuggestion` setting is read at startup; `@../../<repo>/`
   won't complete until you restart.

## Verify

Standalone, before restarting (the script reads a JSON query on stdin, one path per line out).
Replace `../../<repo>` with a path you actually granted in `additionalDirectories`:

```bash
printf '{"query":"../../<repo>"}' | .claude/file-suggestion.sh   # ranked matches under the repo
printf '{"query":""}'             | .claude/file-suggestion.sh   # ./, then root folders, then files
printf '{"query":"zzznope"}'      | .claude/file-suggestion.sh   # nothing, exit 0
echo "exit: $?"
```

Then restart and type `@../../<repo>/` in the picker — folders (trailing `/`) and files from
inside the granted repo should appear.
