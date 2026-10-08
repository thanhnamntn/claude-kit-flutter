#!/usr/bin/env bash
# Install the .claude kit into a project.
# Usage: ./install.sh <project_dir> [--preset flutter] [--force]
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
TARGET=""
PRESET=""
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --preset) PRESET="${2:-}"; shift 2 ;;
    --force) FORCE=1; shift ;;
    -h|--help) sed -n '2,3p' "$0"; exit 0 ;;
    *) TARGET="$1"; shift ;;
  esac
done

[ -n "$TARGET" ] && [ -d "$TARGET" ] || { echo "A valid <project_dir> is required"; exit 1; }
if [ -n "$PRESET" ] && [ ! -d "$KIT/presets/$PRESET" ]; then
  echo "Preset does not exist: $PRESET (available: $(ls "$KIT/presets" | tr '\n' ' '))"; exit 1
fi

DEST="$TARGET/.claude"
mkdir -p "$DEST"
copied=0; skipped=0

# copy_tree <src_dir>: copy each file into $DEST, never overwriting unless --force
copy_tree() {
  local src="$1"
  [ -d "$src" ] || return 0
  while IFS= read -r f; do
    rel="${f#$src/}"
    case "$rel" in CLAUDE.md.template|CLAUDE.md.fragment|.gitkeep) continue ;; esac
    out="$DEST/$rel"
    mkdir -p "$(dirname "$out")"
    if [ -e "$out" ] && [ "$FORCE" -eq 0 ]; then
      echo "  skipped (exists): .claude/$rel"; skipped=$((skipped+1))
    else
      cp "$f" "$out"; echo "  + .claude/$rel"; copied=$((copied+1))
    fi
  done < <(find "$src" -type f)
}

echo "Installing core..."
copy_tree "$KIT/core"
if [ -n "$PRESET" ]; then
  echo "Installing preset $PRESET (overrides core files with the same name)..."
  # preset takes priority over core for files with the same name (e.g. commands/check.md)
  OLD_FORCE=$FORCE; FORCE=1
  # only overwrite files installed by the kit; user-modified files are kept unless --force
  while IFS= read -r f; do
    rel="${f#$KIT/presets/$PRESET/}"
    case "$rel" in CLAUDE.md.fragment|.gitkeep) continue ;; esac
    out="$DEST/$rel"; mkdir -p "$(dirname "$out")"
    if [ -e "$out" ] && [ "$OLD_FORCE" -eq 0 ] && ! cmp -s "$KIT/core/$rel" "$out" 2>/dev/null; then
      echo "  skipped (customized): .claude/$rel"; skipped=$((skipped+1))
    else
      cp "$f" "$out"; echo "  + .claude/$rel"; copied=$((copied+1))
    fi
  done < <(find "$KIT/presets/$PRESET" -type f)
  FORCE=$OLD_FORCE
fi

# STRUCTURE.md belongs in the project root (not .claude/): move it out if not present
if [ -f "$DEST/STRUCTURE.md" ]; then
  if [ -e "$TARGET/STRUCTURE.md" ]; then
    rm "$DEST/STRUCTURE.md"; echo "  skipped (exists): STRUCTURE.md"
  else
    mv "$DEST/STRUCTURE.md" "$TARGET/STRUCTURE.md"; echo "  + STRUCTURE.md"
  fi
fi
chmod +x "$DEST/scripts/"*.sh 2>/dev/null || true

# CLAUDE.md: never overwrite
CLAUDE="$TARGET/CLAUDE.md"
if [ -e "$CLAUDE" ]; then
  CLAUDE="$TARGET/CLAUDE.md.kit-new"
  echo "CLAUDE.md already exists → writing the template to $(basename "$CLAUDE") for you to merge manually."
fi
{
  cat "$KIT/core/CLAUDE.md.template"
  if [ -n "$PRESET" ] && [ -f "$KIT/presets/$PRESET/CLAUDE.md.fragment" ]; then
    printf '\n<!-- preset: %s -->\n' "$PRESET"
    cat "$KIT/presets/$PRESET/CLAUDE.md.fragment"
  fi
} > "$CLAUDE"

echo
echo "Done: $copied new files, $skipped skipped. Next:"
echo "  1. Fill in/merge $(basename "$CLAUDE") (overview, Commands, Architecture)."
echo "  2. Adjust the 'paths:' frontmatter in .claude/rules/*.md to match the project directories."
echo "  3. Add the required Bash permissions to .claude/settings.json."
