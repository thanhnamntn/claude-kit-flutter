#!/usr/bin/env bash
# Check the lib/ structure against STRUCTURE.md and .claude/rules/imports.md.
# Run from the project root:  bash scripts/check_structure.sh
# Exits 1 on violations. Never modifies files.
set -u

# Find the project root (where pubspec.yaml is) by walking up from the script location
dir="$(cd "$(dirname "$0")" && pwd)"
while [ "$dir" != "/" ] && [ ! -f "$dir/pubspec.yaml" ]; do dir="$(dirname "$dir")"; done
[ -f "$dir/pubspec.yaml" ] || { echo "pubspec.yaml not found"; exit 2; }
cd "$dir"
PROJECT="$(grep -m1 '^name:' pubspec.yaml | awk '{print $2}')"
fail=0

report() { # report <title> <content> [warn]  — warn: warning only, does not fail
  if [ -n "$2" ]; then
    if [ "${3:-}" = "warn" ]; then echo "! $1 (tech debt, non-blocking)"; else echo "✗ $1"; fail=1; fi
    echo "$2" | sed 's/^/    /'
  else
    echo "✓ $1"
  fi
}

# 1. Folders with >= 3 .dart files must have an index.dart
# (skip dev_token.dart because it is gitignored; core/providers/{datasource,repository,usecase} are combined in core/providers/index.dart)
out=""
while IFS= read -r d; do
  case "$d" in lib/core/providers/datasource|lib/core/providers/repository|lib/core/providers/usecase) continue ;; esac
  n=$(find "$d" -maxdepth 1 -name '*.dart' ! -name index.dart ! -name dev_token.dart | wc -l | tr -d ' ')
  if [ "$n" -ge 3 ] && [ ! -f "$d/index.dart" ]; then out="$out$d ($n files)"$'\n'; fi
done < <(find lib -type d)
report "Folders with >= 3 .dart files have index.dart" "${out%$'\n'}"

# 2. index.dart exports every file in the folder (core/providers: including subfolders)
out=""
while IFS= read -r idx; do
  d="$(dirname "$idx")"
  if [ "$d" = "lib/core/providers" ]; then
    files=$(find "$d" -name '*.dart' ! -name index.dart | sed "s#^$d/##")
  else
    files=$(find "$d" -maxdepth 1 -name '*.dart' ! -name index.dart ! -name dev_token.dart | sed "s#^$d/##")
  fi
  for f in $files; do
    grep -q "export '$f'" "$idx" || out="$out$idx: missing export $f"$'\n'
  done
done < <(find lib -name index.dart)
report "index.dart exports all files" "${out%$'\n'}"

# 3. Relative imports
out=$(grep -rnE "^(import|export) '(\.\./|\./)" lib | cut -c1-140)
report "No relative imports (always package:)" "$out"

# 4. Dependency direction
dep() { # dep <label> <source dir> <forbidden import regex>
  local o
  o=$(grep -rnE "^(import|export) 'package:$PROJECT/($3)" $2 | cut -c1-140)
  report "$1" "$o"
}
dep "domain does not import data/share/features/core-providers" lib/domain "data/|share/|features/|core/providers/"
dep "features do not import data/" lib/features "data/"
dep "share does not import features/" lib/share "features/"
dep "data does not import share/features/" lib/data "share/|features/"
dep "core does not import share/features/" lib/core "share/|features/"

# 5. Pure Dart domain (no Flutter / easy_localization)
out=$(grep -rnE "^import 'package:(flutter|easy_localization)/" lib/domain | cut -c1-140)
report "domain does not import Flutter/easy_localization" "$out" warn

# 6. BE enum strings (toGraphQL/fromGraphQL) only in data
out=$(grep -rnwE "toGraphQL|fromGraphQL" lib/domain lib/features lib/share lib/core lib/app_routes.dart 2>/dev/null | cut -c1-140)
report "toGraphQL/fromGraphQL used only in data/" "$out"

# 7. Feature layout: only pages/notifiers/state/widgets
out=""
for f in lib/features/*/; do
  for sub in $(ls "$f"); do
    case "$sub" in pages|notifiers|state|widgets) ;; *) out="$out$f$sub (not one of pages/notifiers/state/widgets)"$'\n' ;; esac
  done
done
report "Features only have pages/notifiers/state/widgets" "${out%$'\n'}"

# 8. Leftover presenter / presentation
out=$(find lib -type d \( -name presentation -o -name presenters \) ; grep -rliE "presenter" lib | sed 's/$/ (mentions "presenter")/')
report "No leftover presenter/presentation" "$out"

# 9. snake_case file names
out=$(find lib -name '*.dart' | awk -F/ '{print $NF}' | grep -E '[A-Z-]' )
report "snake_case file names" "$out"

# 9b. models/ only exists in data/ (Model = BE response)
out=$(find lib -type d -name models ! -path 'lib/data/models')
report "models/ folder only in data/" "$out"

# 10. STRUCTURE.md matches reality (skipped if the project has no STRUCTURE.md)
out=""
if [ -f STRUCTURE.md ]; then
for d in $(ls -d lib/*/ | xargs -n1 basename); do
  grep -qE "(├|└)── $d/" STRUCTURE.md || out="$out""lib/$d/ is not in STRUCTURE.md"$'\n'
done
for f in $(ls lib/environment/*.dart | xargs -n1 basename); do
  grep -q "$f" STRUCTURE.md || out="$out""environment/$f is not in STRUCTURE.md"$'\n'
done
for f in $(sed -n '/environment\//,/features\//p' STRUCTURE.md | grep -oE '[a-z_]+\.dart' | sort -u); do
  [ -f "lib/environment/$f" ] || out="$out""STRUCTURE.md lists environment/$f but the file does not exist"$'\n'
done
for d in $(ls -d lib/features/shell/ lib/share/*/ lib/share/widgets/*/ lib/core/*/ lib/core/providers/*/ lib/domain/*/ lib/data/*/ | xargs -n1 basename | sort -u); do
  grep -qE "(├|└)── $d/|^[│ ]+[├└]── $d/" STRUCTURE.md || out="$out""folder '$d/' is not in STRUCTURE.md"$'\n'
done
report "STRUCTURE.md matches reality" "${out%$'\n'}"
else echo "- skipped: no STRUCTURE.md"; fi

echo
if [ "$fail" -eq 0 ]; then echo "OK: structure is valid"; else echo "FAIL: structure violations found"; fi
exit "$fail"
