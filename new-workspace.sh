#!/usr/bin/env bash
# Bootstrap a Claude Code SDD workspace that symlinks one or more sibling repos.
#
# Usage:
#   ./new-workspace.sh [--specs workspace|per-repo] <parent-dir> <workspace-name> <repo> [<repo2> ...]
#
# Result:
#   <parent-dir>/workspaces/<workspace-name>/   (copy of template/)
#     └── <repo> -> ../../<repo>                 (one symlink per repo)
#
# Spec model (--specs, default: workspace):
#   workspace  Specs live in the workspace's own specs/ (repos untouched).
#   per-repo   Specs live inside each linked repo's specs/ (versioned with that repo).
#              The workspace's specs/ is removed and each repo gets a specs/ scaffold
#              (skipped for a repo that already has one, or whose symlink doesn't resolve).
#
# After running, fill in the <...> placeholders in CLAUDE.md, CONTEXT.md, README.md,
# .claude/settings.json, and .vscode/settings.json (and delete the spec-model paragraph
# that doesn't apply).
set -euo pipefail

SPECS="workspace"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --specs) SPECS="${2:-}"; shift 2 ;;
    --specs=*) SPECS="${1#*=}"; shift ;;
    --) shift; break ;;
    -*) echo "unknown option: $1" >&2; exit 1 ;;
    *) break ;;
  esac
done

case "$SPECS" in
  workspace|per-repo) ;;
  *) echo "--specs must be 'workspace' or 'per-repo' (got: $SPECS)" >&2; exit 1 ;;
esac

if [ "$#" -lt 3 ]; then
  echo "usage: $0 [--specs workspace|per-repo] <parent-dir> <workspace-name> <repo> [<repo2> ...]" >&2
  exit 1
fi

PARENT="$1"; shift
NAME="$1"; shift
REPOS=("$@")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/template"
PER_REPO_SRC="$SCRIPT_DIR/spec-model-per-repo"
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

# wire up the chosen spec model
if [ "$SPECS" = "per-repo" ]; then
  [ -d "$PER_REPO_SRC" ] || { echo "missing per-repo scaffold: $PER_REPO_SRC" >&2; exit 1; }
  # the workspace doesn't own specs in this model
  rm -rf "$DEST/specs"
  for repo in "${REPOS[@]}"; do
    target="$DEST/$repo/specs"   # follows the symlink into the real repo
    if [ ! -d "$DEST/$repo" ]; then
      echo "  skip specs: $repo symlink doesn't resolve" >&2
    elif [ -e "$target" ]; then
      echo "  skip specs: $repo/specs already exists (left untouched)"
    else
      mkdir -p "$target/done"
      cp "$PER_REPO_SRC/README.md" "$target/README.md"
      cp "$PER_REPO_SRC/_TEMPLATE.md" "$target/_TEMPLATE.md"
      touch "$target/done/.gitkeep"
      echo "  specs: created $repo/specs/ (README, _TEMPLATE, done/)"
    fi
  done
fi

echo "created $DEST (spec model: $SPECS)"
echo "next: replace <...> placeholders in CLAUDE.md, CONTEXT.md, README.md, .claude/settings.json, .vscode/settings.json"
echo "      and delete the spec-model paragraph that doesn't apply in CLAUDE.md / README.md"
