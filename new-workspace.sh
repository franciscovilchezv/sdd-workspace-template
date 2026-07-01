#!/usr/bin/env bash
# Bootstrap a Claude Code SDD workspace that symlinks one or more sibling repos.
#
# Usage:
#   ./new-workspace.sh <parent-dir> <workspace-name> <repo> [<repo2> ...]
#
# Result:
#   <parent-dir>/workspaces/<workspace-name>/   (copy of template/)
#     └── <repo> -> ../../<repo>                 (one symlink per repo)
#
# After running, fill in the <...> placeholders in CLAUDE.md, CONTEXT.md, README.md,
# .claude/settings.json, and .vscode/settings.json.
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "usage: $0 <parent-dir> <workspace-name> <repo> [<repo2> ...]" >&2
  exit 1
fi

PARENT="$1"; shift
NAME="$1"; shift
REPOS=("$@")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/template"
DEST="$PARENT/workspaces/$NAME"

[ -d "$SRC" ] || { echo "missing template dir: $SRC" >&2; exit 1; }
[ -e "$DEST" ] && { echo "destination already exists: $DEST" >&2; exit 1; }

mkdir -p "$DEST"
# copy template contents (including dotfiles), preserving structure
cp -R "$SRC/." "$DEST/"

# create one ../../<repo> symlink per repo and verify it resolves
for repo in "${REPOS[@]}"; do
  ln -sfn "../../$repo" "$DEST/$repo"
  if [ -d "$DEST/$repo" ]; then
    echo "  ok: $repo -> ../../$repo"
  else
    echo "  WARN: $repo -> ../../$repo does not resolve (is $PARENT/$repo present?)" >&2
  fi
done

echo "created $DEST"
echo "next: replace <...> placeholders in CLAUDE.md, CONTEXT.md, README.md, .claude/settings.json, .vscode/settings.json"
