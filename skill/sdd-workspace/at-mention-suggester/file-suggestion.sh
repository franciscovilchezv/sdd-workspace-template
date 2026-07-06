#!/usr/bin/env bash
#
# Custom @-mention file suggester for Claude Code.
#
# Why: the built-in @ picker only walks the workspace root, so it has no awareness
# of `permissions.additionalDirectories` — the sibling repos this workspace grants
# access to by their real path (e.g. ../../my-app) instead of copying or symlinking
# them in. This script reads that setting at query time and emits candidates from
# each additional directory too, prefixed with exactly the path the user would type
# (e.g. ../../my-app/src/foo.ts).
#
# It is repo-agnostic: everything comes from `additionalDirectories`, so it drops
# into any workspace built from this template unchanged — no per-repo edits.
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

# --- resolve additionalDirectories from settings ---------------------------------
# Merge `permissions.additionalDirectories` from settings.json and settings.local.json
# (either file may be absent or omit the key). Order preserved, duplicates dropped.
# Needs jq; without it, additional dirs are simply skipped (root-only suggestions).
additional_dirs() {
  command -v jq >/dev/null 2>&1 || return 0
  jq -rs '
    [.[] | .permissions.additionalDirectories? // [] | .[]]
    | unique
    | .[]
  ' <(cat .claude/settings.json 2>/dev/null || echo '{}') \
    <(cat .claude/settings.local.json 2>/dev/null || echo '{}') 2>/dev/null || true
}

# --- list candidates (dirs + files) ---------------------------------------------
# --exclude .git/node_modules and --hidden keep the list to real, relevant entries;
# fd also honors .gitignore inside each directory it walks.
fd_base() {
  fd --hidden --exclude .git --exclude node_modules "$@"
}

# Root candidates, in browse order for the no-query case:
#   1. "./"  — the current directory itself (so it can be tagged).
#   2. directories (fd appends a trailing "/", so folders read as folder mentions).
#   3. files.
root_candidates() {
  printf './\n'
  fd_base --type d
  fd_base --type f
}

# Candidates for one additional directory, prefixed with the literal path (`rel`,
# e.g. "../../my-app") the user would type — mirrors root_candidates' "./" + dirs +
# files shape, but rooted at `rel` instead of ".".
additional_candidates() {
  local rel="$1"
  rel="${rel%/}"
  [ -d "$rel" ] || return 0
  printf '%s/\n' "$rel"
  fd_base --type d --base-directory "$rel" | sed "s|^|$rel/|"
  fd_base --type f --base-directory "$rel" | sed "s|^|$rel/|"
}

all_candidates() {
  root_candidates
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    additional_candidates "$d"
  done < <(additional_dirs)
}

# Empty query: root candidates only (additional dirs aren't force-injected, to
# avoid flooding the default list with a large sibling repo's tree).
if [ -z "$query" ]; then
  root_candidates | sed -n "1,${MAX}p"
  exit 0
fi

# --- rank / filter --------------------------------------------------------------
# Preferred: fzf --filter gives proper fuzzy ranking (best matches first), which
# matters because the picker only shows the top handful. Capturing into a var (no
# mid-pipe `head`) avoids SIGPIPE surfacing as a non-zero exit under pipefail;
# we trim to MAX afterward with sed.
if command -v fzf >/dev/null 2>&1; then
  results="$(all_candidates | fzf --filter="$query" 2>/dev/null || true)"
  printf '%s\n' "$results" | sed '/^$/d' | sed -n "1,${MAX}p"
  exit 0
fi

# Fallback (no fzf): split the query on '/', escape each segment's regex
# metacharacters, and rejoin with '.*'. So "my-app/settings" -> "my-app.*settings",
# matching "../../my-app/app/(app)/settings/..." across intermediate dirs; "roles"
# stays a plain substring. Match against the whole candidate line (dirs included).
esc() { printf '%s' "$1" | sed 's/[][(){}.^$*+?|\\]/\\&/g'; }
pattern=""
IFS='/' read -ra parts <<<"$query"
for p in "${parts[@]}"; do
  [ -z "$p" ] && continue
  if [ -z "$pattern" ]; then pattern="$(esc "$p")"; else pattern="$pattern.*$(esc "$p")"; fi
done
all_candidates | grep -iE -- "$pattern" | sed -n "1,${MAX}p"
