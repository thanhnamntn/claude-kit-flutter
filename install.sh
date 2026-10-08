#!/usr/bin/env bash
# Cài bộ .claude vào một project.
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

[ -n "$TARGET" ] && [ -d "$TARGET" ] || { echo "Cần <project_dir> hợp lệ"; exit 1; }
if [ -n "$PRESET" ] && [ ! -d "$KIT/presets/$PRESET" ]; then
  echo "Preset không tồn tại: $PRESET (có: $(ls "$KIT/presets" | tr '\n' ' '))"; exit 1
fi

DEST="$TARGET/.claude"
mkdir -p "$DEST"
copied=0; skipped=0

# copy_tree <src_dir> : copy từng file vào $DEST, không ghi đè trừ khi --force
copy_tree() {
  local src="$1"
  [ -d "$src" ] || return 0
  while IFS= read -r f; do
    rel="${f#$src/}"
    case "$rel" in CLAUDE.md.template|CLAUDE.md.fragment|.gitkeep) continue ;; esac
    out="$DEST/$rel"
    mkdir -p "$(dirname "$out")"
    if [ -e "$out" ] && [ "$FORCE" -eq 0 ]; then
      echo "  bỏ qua (đã có): .claude/$rel"; skipped=$((skipped+1))
    else
      cp "$f" "$out"; echo "  + .claude/$rel"; copied=$((copied+1))
    fi
  done < <(find "$src" -type f)
}

echo "Cài core..."
copy_tree "$KIT/core"
if [ -n "$PRESET" ]; then
  echo "Cài preset $PRESET (ghi đè file core cùng tên)..."
  # preset ưu tiên hơn core cho các file trùng tên (vd commands/check.md)
  OLD_FORCE=$FORCE; FORCE=1
  # chỉ ghi đè file do kit cài; file người dùng tự sửa vẫn được giữ nếu không --force
  while IFS= read -r f; do
    rel="${f#$KIT/presets/$PRESET/}"
    case "$rel" in CLAUDE.md.fragment|.gitkeep) continue ;; esac
    out="$DEST/$rel"; mkdir -p "$(dirname "$out")"
    if [ -e "$out" ] && [ "$OLD_FORCE" -eq 0 ] && ! cmp -s "$KIT/core/$rel" "$out" 2>/dev/null; then
      echo "  bỏ qua (đã tùy chỉnh): .claude/$rel"; skipped=$((skipped+1))
    else
      cp "$f" "$out"; echo "  + .claude/$rel"; copied=$((copied+1))
    fi
  done < <(find "$KIT/presets/$PRESET" -type f)
  FORCE=$OLD_FORCE
fi

# STRUCTURE.md thuộc gốc project (không phải .claude/): chuyển ra nếu chưa có
if [ -f "$DEST/STRUCTURE.md" ]; then
  if [ -e "$TARGET/STRUCTURE.md" ]; then
    rm "$DEST/STRUCTURE.md"; echo "  bỏ qua (đã có): STRUCTURE.md"
  else
    mv "$DEST/STRUCTURE.md" "$TARGET/STRUCTURE.md"; echo "  + STRUCTURE.md"
  fi
fi
chmod +x "$DEST/scripts/"*.sh 2>/dev/null || true

# CLAUDE.md: không bao giờ ghi đè
CLAUDE="$TARGET/CLAUDE.md"
if [ -e "$CLAUDE" ]; then
  CLAUDE="$TARGET/CLAUDE.md.kit-new"
  echo "CLAUDE.md đã tồn tại → ghi bản mẫu vào $(basename "$CLAUDE") để bạn tự gộp."
fi
{
  cat "$KIT/core/CLAUDE.md.template"
  if [ -n "$PRESET" ] && [ -f "$KIT/presets/$PRESET/CLAUDE.md.fragment" ]; then
    printf '\n<!-- preset: %s -->\n' "$PRESET"
    cat "$KIT/presets/$PRESET/CLAUDE.md.fragment"
  fi
} > "$CLAUDE"

echo
echo "Xong: $copied file mới, $skipped bỏ qua. Tiếp theo:"
echo "  1. Điền/gộp $(basename "$CLAUDE") (tổng quan, Commands, Kiến trúc)."
echo "  2. Chỉnh frontmatter 'paths:' trong .claude/rules/*.md cho khớp thư mục project."
echo "  3. Thêm quyền Bash cần thiết vào .claude/settings.json."
