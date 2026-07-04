# Optional module: `@`-mention file suggester

A drop-in script that makes `@<repo>/…` autocomplete into the linked repos.

## Why

A workspace links its repos as **symlinks that point outside the workspace root**. Claude Code's
built-in `@` picker walks the filesystem from the project root but **does not descend into
symlinked directories that leave that root** — so `@<repo>/…` completes nothing, and the linked
repos' files are unreachable via `@`-mentions.

This module replaces the picker with a small script wired in through Claude Code's `fileSuggestion`
setting. The script does an `fd --follow` walk that reaches through the symlinks and emits
`<repo>/…`-prefixed candidates — **folders** (with a trailing `/`) and **files**, plus `./` for the
current directory, so any of them can be `@`-tagged. It is **repo-agnostic** — it discovers every
symlinked repo under the workspace root, so it needs no per-repo configuration and no placeholder
filling.

This is **opt-in** (unlike the rest of `template/`, which is copied wholesale) because it needs
`fd` on `PATH`. Skip it if you don't have `fd` or don't want a custom picker.

## Dependencies

- **`fd`** — required (https://github.com/sharkdp/fd). The walk uses `fd --follow`; without it the
  script fails. Install: `brew install fd` / `apt install fd-find` / `cargo install fd-find`.
- **`fzf`** — optional; enables proper fuzzy ranking (best matches first). Without it the script
  falls back to an `fd` regex matcher.
- **`jq`** — optional; parses the stdin query JSON. Without it the script treats raw stdin as the
  query.

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
3. **Document it in the workspace `CLAUDE.md`** — paste this under a heading near the top so
   Claude knows the picker is customized:
   ```markdown
   ## `@`-mention file suggestions across the symlinks

   The linked repos are symlinks that point outside this workspace root, and Claude Code's
   built-in `@` picker doesn't descend into symlinks that leave the project — so `@<repo>/…`
   wouldn't autocomplete on its own. `.claude/file-suggestion.sh` (wired in via the
   `fileSuggestion` setting in `.claude/settings.json`) replaces the picker with an `fd --follow`
   walk that reaches through the symlinks. It's repo-agnostic — no per-repo config. **Requires
   `fd`** on `PATH` (`fzf`/`jq` optional, for ranking/parsing).
   ```
4. **Restart Claude Code** — the `fileSuggestion` setting is read at startup; `@<repo>/` won't
   complete until you restart.

## Verify

Standalone, before restarting (the script reads a JSON query on stdin, one path per line out):

```bash
printf '{"query":"<repo>"}' | .claude/file-suggestion.sh     # ranked matches under the repo
printf '{"query":""}'       | .claude/file-suggestion.sh     # ./, then folders, then files
printf '{"query":"zzznope"}'| .claude/file-suggestion.sh     # nothing, exit 0
echo "exit: $?"
```

Then restart and type `@<repo>/` in the picker — folders (trailing `/`) and files from inside the
linked repo should appear.
