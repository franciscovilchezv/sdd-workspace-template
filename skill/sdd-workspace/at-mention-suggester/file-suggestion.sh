#!/usr/bin/env bash
#
# Custom @-mention file suggester for Claude Code.
#
# Why: this workspace links its repos as symlinks that point OUTSIDE the workspace
# root, and Claude Code's built-in @ picker does not descend into symlinked
# directories that leave the project root — so `@<repo>/...` never autocompletes.
# This script uses `fd --follow` to walk through those symlinks, emitting
# `<repo>/...`-prefixed paths that match exactly what the user types. It is
# repo-agnostic: it discovers every symlinked repo under the workspace root, so it
# drops into any workspace built from this template unchanged.
#
# Wired in via `.claude/settings.json` -> "fileSuggestion": { "type": "command", ... }.
# Claude invokes it with a JSON query on stdin and reads candidate paths from stdout
# (one per line).
#
# Requires `fd` (https://github.com/sharkdp/fd). `fzf` and `jq` are optional — the
# script degrades gracefully without them (see the fallbacks below).

set -euo pipefail

# Workspace root = parent of this script's .claude/ dir. Robust regardless of cwd.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAX=20

# --- read the query -------------------------------------------------------------
# Claude sends a JSON object on stdin, verified as:
#   {"session_id":..., "transcript_path":..., "cwd":..., "query":"<text after @>"}
# We only need `.query` (which may legitimately be empty). Fall back to raw text if
# stdin ever isn't JSON.
raw="$(cat)"
if command -v jq >/dev/null 2>&1 && printf '%s' "$raw" | jq -e . >/dev/null 2>&1; then
  query="$(printf '%s' "$raw" | jq -r '.query // ""')"
else
  query="$(printf '%s' "$raw" | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
fi

cd "$ROOT"

# --- list candidate files -------------------------------------------------------
# --follow: traverse the linked-repo symlinks. fd honors .gitignore, so each repo's
# node_modules/build output is excluded automatically. `--type f --hidden` with .git
# and node_modules excluded keeps the list to real, relevant source files.
fd_list() {
  fd --follow --type f --hidden --exclude .git --exclude node_modules "$@"
}

# Empty query: just return the first MAX files (no ranking to do).
if [ -z "$query" ]; then
  fd_list --max-results "$MAX" .
  exit 0
fi

# --- rank / filter --------------------------------------------------------------
# Preferred: fzf --filter gives proper fuzzy ranking (best matches first), which
# matters because the picker only shows the top handful. Capturing into a var (no
# mid-pipe `head`) avoids SIGPIPE surfacing as a non-zero exit under pipefail;
# we trim to MAX afterward with sed.
if command -v fzf >/dev/null 2>&1; then
  results="$(fd_list | fzf --filter="$query" 2>/dev/null || true)"
  printf '%s\n' "$results" | sed '/^$/d' | sed -n "1,${MAX}p"
  exit 0
fi

# Fallback (no fzf): split the query on '/', escape each segment's regex
# metacharacters, and rejoin with '.*'. So "<repo>/settings" -> "<repo>.*settings",
# matching "<repo>/app/(app)/settings/..." across intermediate dirs; "roles" stays a
# plain substring. --full-path matches against the whole path.
esc() { printf '%s' "$1" | sed 's/[][(){}.^$*+?|\\]/\\&/g'; }
pattern=""
IFS='/' read -ra parts <<<"$query"
for p in "${parts[@]}"; do
  [ -z "$p" ] && continue
  if [ -z "$pattern" ]; then pattern="$(esc "$p")"; else pattern="$pattern.*$(esc "$p")"; fi
done
fd_list --ignore-case --full-path --max-results "$MAX" -- "$pattern"
