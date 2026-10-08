#!/usr/bin/env bash
# Kiểm tra cấu trúc lib/ theo STRUCTURE.md và .claude/rules/imports.md.
# Chạy từ thư mục gốc project:  bash scripts/check_structure.sh
# Exit 1 nếu có vi phạm. Không sửa file.
set -u

# Tìm thư mục gốc project (nơi có pubspec.yaml) đi ngược từ vị trí script
dir="$(cd "$(dirname "$0")" && pwd)"
while [ "$dir" != "/" ] && [ ! -f "$dir/pubspec.yaml" ]; do dir="$(dirname "$dir")"; done
[ -f "$dir/pubspec.yaml" ] || { echo "Không tìm thấy pubspec.yaml"; exit 2; }
cd "$dir"
PROJECT="$(grep -m1 '^name:' pubspec.yaml | awk '{print $2}')"
fail=0

report() { # report <tiêu đề> <nội dung> [warn]  — warn: chỉ cảnh báo, không làm fail
  if [ -n "$2" ]; then
    if [ "${3:-}" = "warn" ]; then echo "! $1 (nợ kỹ thuật, không chặn)"; else echo "✗ $1"; fail=1; fi
    echo "$2" | sed 's/^/    /'
  else
    echo "✓ $1"
  fi
}

# 1. Folder có >= 3 file .dart phải có index.dart
# (bỏ qua dev_token.dart vì gitignore; core/providers/{datasource,repository,usecase} gộp ở core/providers/index.dart)
out=""
while IFS= read -r d; do
  case "$d" in lib/core/providers/datasource|lib/core/providers/repository|lib/core/providers/usecase) continue ;; esac
  n=$(find "$d" -maxdepth 1 -name '*.dart' ! -name index.dart ! -name dev_token.dart | wc -l | tr -d ' ')
  if [ "$n" -ge 3 ] && [ ! -f "$d/index.dart" ]; then out="$out$d ($n file)"$'\n'; fi
done < <(find lib -type d)
report "Folder >= 3 file .dart có index.dart" "${out%$'\n'}"

# 2. index.dart export đủ file trong folder (core/providers: gồm cả folder con)
out=""
while IFS= read -r idx; do
  d="$(dirname "$idx")"
  if [ "$d" = "lib/core/providers" ]; then
    files=$(find "$d" -name '*.dart' ! -name index.dart | sed "s#^$d/##")
  else
    files=$(find "$d" -maxdepth 1 -name '*.dart' ! -name index.dart ! -name dev_token.dart | sed "s#^$d/##")
  fi
  for f in $files; do
    grep -q "export '$f'" "$idx" || out="$out$idx: thiếu export $f"$'\n'
  done
done < <(find lib -name index.dart)
report "index.dart export đủ file" "${out%$'\n'}"

# 3. Import tương đối
out=$(grep -rnE "^(import|export) '(\.\./|\./)" lib | cut -c1-140)
report "Không dùng import tương đối (luôn package:)" "$out"

# 4. Hướng phụ thuộc
dep() { # dep <nhãn> <thư mục nguồn> <regex import bị cấm>
  local o
  o=$(grep -rnE "^(import|export) 'package:$PROJECT/($3)" $2 | cut -c1-140)
  report "$1" "$o"
}
dep "domain không import data/share/features/core-providers" lib/domain "data/|share/|features/|core/providers/"
dep "features không import data/" lib/features "data/"
dep "share không import features/" lib/share "features/"
dep "data không import share/features/" lib/data "share/|features/"
dep "core không import share/features/" lib/core "share/|features/"

# 5. Domain thuần Dart (không Flutter / easy_localization)
out=$(grep -rnE "^import 'package:(flutter|easy_localization)/" lib/domain | cut -c1-140)
report "domain không import Flutter/easy_localization" "$out" warn

# 6. BE enum string (toGraphQL/fromGraphQL) chỉ ở data
out=$(grep -rnwE "toGraphQL|fromGraphQL" lib/domain lib/features lib/share lib/core lib/app_routes.dart 2>/dev/null | cut -c1-140)
report "toGraphQL/fromGraphQL chỉ dùng trong data/" "$out"

# 7. Layout feature: chỉ pages/notifiers/state/widgets
out=""
for f in lib/features/*/; do
  for sub in $(ls "$f"); do
    case "$sub" in pages|notifiers|state|widgets) ;; *) out="$out$f$sub (không thuộc pages/notifiers/state/widgets)"$'\n' ;; esac
  done
done
report "Feature chỉ có pages/notifiers/state/widgets" "${out%$'\n'}"

# 8. Còn presenter / presentation
out=$(find lib -type d \( -name presentation -o -name presenters \) ; grep -rliE "presenter" lib | sed 's/$/ (nhắc "presenter")/')
report "Không còn presenter/presentation" "$out"

# 9. Tên file snake_case
out=$(find lib -name '*.dart' | awk -F/ '{print $NF}' | grep -E '[A-Z-]' )
report "Tên file snake_case" "$out"

# 9b. models/ chỉ nằm ở data/ (Model = response BE)
out=$(find lib -type d -name models ! -path 'lib/data/models')
report "Folder models/ chỉ có trong data/" "$out"

# 10. STRUCTURE.md khớp thực tế (bỏ qua nếu project chưa có STRUCTURE.md)
out=""
if [ -f STRUCTURE.md ]; then
for d in $(ls -d lib/*/ | xargs -n1 basename); do
  grep -qE "(├|└)── $d/" STRUCTURE.md || out="$out""lib/$d/ chưa có trong STRUCTURE.md"$'\n'
done
for f in $(ls lib/environment/*.dart | xargs -n1 basename); do
  grep -q "$f" STRUCTURE.md || out="$out""environment/$f chưa có trong STRUCTURE.md"$'\n'
done
for f in $(sed -n '/environment\//,/features\//p' STRUCTURE.md | grep -oE '[a-z_]+\.dart' | sort -u); do
  [ -f "lib/environment/$f" ] || out="$out""STRUCTURE.md ghi environment/$f nhưng file không tồn tại"$'\n'
done
for d in $(ls -d lib/features/shell/ lib/share/*/ lib/share/widgets/*/ lib/core/*/ lib/core/providers/*/ lib/domain/*/ lib/data/*/ | xargs -n1 basename | sort -u); do
  grep -qE "(├|└)── $d/|^[│ ]+[├└]── $d/" STRUCTURE.md || out="$out""folder '$d/' chưa có trong STRUCTURE.md"$'\n'
done
report "STRUCTURE.md khớp thực tế" "${out%$'\n'}"
else echo "- bỏ qua: không có STRUCTURE.md"; fi

echo
if [ "$fail" -eq 0 ]; then echo "OK: cấu trúc hợp lệ"; else echo "FAIL: có vi phạm cấu trúc"; fi
exit "$fail"
