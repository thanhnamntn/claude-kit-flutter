#!/usr/bin/env python3
"""Kiểm tra translation của project Flutter (easy_localization).

Usage (từ thư mục gốc project):
  python3 .claude/skills/check-translations/scripts/check_translations.py [--hardcoded]

Kiểm tra:
  1. Key có ở ngôn ngữ này nhưng thiếu ở ngôn ngữ kia.
  2. Key dùng trong code (`'a.b'.tr(`, `tr('a.b'`, `plural('a.b'`) nhưng không tồn tại.
  3. Key định nghĩa nhưng không được dùng (bỏ qua key có thể được ghép động).
  4. Giá trị rỗng, và placeholder `{}` / `{name}` không khớp giữa các ngôn ngữ.
  5. (--hardcoded) Text hiển thị hard-code trong Text('...') / label / hint... chưa dịch.
Exit code 1 nếu có lỗi mức 1, 2 hoặc 4.
"""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path.cwd()
TRANS_DIR = ROOT / 'assets' / 'translations'
SRC_DIRS = [ROOT / 'lib']

KEY_PATTERNS = [
    re.compile(r"""['"]([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)+)['"]\s*\.(?:tr|plural)\("""),
    re.compile(r"""\b(?:tr|plural)\(\s*['"]([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)+)['"]"""),
]
LITERAL_PATTERN = re.compile(r"""['"]([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)+)['"]""")
DYNAMIC_PATTERN = re.compile(r"""['"]([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)*\.)\$\{?[A-Za-z_]""")
FILE_SUFFIXES = {'dart', 'com', 'org', 'net', 'vn', 'json', 'png', 'jpg', 'svg', 'webp', 'ttf', 'yaml', 'md'}
PLACEHOLDER = re.compile(r'\{[A-Za-z0-9_]*\}')
HARDCODED = re.compile(
    r"""(?:Text\(\s*|(?:label|hint|title|subtitle|content|labelText|hintText|tooltip|message)\s*:\s*)(?:const\s+)?['"]([^'"$\\]*[A-Za-zÀ-ỹ][^'"$\\]*)['"]"""
)


def flatten(d, prefix=''):
    out = {}
    for k, v in d.items():
        key = f'{prefix}{k}'
        if isinstance(v, dict):
            out.update(flatten(v, key + '.'))
        else:
            out[key] = v
    return out


def dart_files():
    for d in SRC_DIRS:
        yield from d.rglob('*.dart')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--hardcoded', action='store_true')
    args = ap.parse_args()

    files = sorted(TRANS_DIR.glob('*.json'))
    if len(files) < 2:
        print(f'Không tìm thấy >= 2 file translation trong {TRANS_DIR}')
        return 1
    langs = {f.stem: flatten(json.loads(f.read_text(encoding='utf-8'))) for f in files}
    names = list(langs)
    errors = 0

    # 1. thiếu key giữa các ngôn ngữ
    print('== 1. Key thiếu giữa các ngôn ngữ ==')
    all_keys = set().union(*[set(v) for v in langs.values()])
    for lang, keys in langs.items():
        missing = sorted(all_keys - set(keys))
        if missing:
            errors += len(missing)
            print(f'  [{lang}] thiếu {len(missing)} key:')
            for k in missing:
                print(f'    - {k}')
    if all(not (all_keys - set(k)) for k in langs.values()):
        print('  OK')

    # 2/3. key dùng trong code
    used = {}
    literals = {}
    dynamic_prefixes = set()
    for f in dart_files():
        text = f.read_text(encoding='utf-8')
        for pat in KEY_PATTERNS:
            for m in pat.finditer(text):
                line = text.count('\n', 0, m.start()) + 1
                used.setdefault(m.group(1), []).append(f'{f.relative_to(ROOT)}:{line}')
        for m in LITERAL_PATTERN.finditer(text):
            line = text.count('\n', 0, m.start()) + 1
            literals.setdefault(m.group(1), []).append(f'{f.relative_to(ROOT)}:{line}')
        for m in DYNAMIC_PATTERN.finditer(text):
            dynamic_prefixes.add(m.group(1))

    defined_all = set().union(*[set(v) for v in langs.values()])
    print('\n== 2. Key dùng trong code nhưng chưa định nghĩa ==')
    undefined = {k: v for k, v in used.items() if any(k not in langs[l] for l in names)}
    if undefined:
        for k, locs in sorted(undefined.items()):
            miss = [l for l in names if k not in langs[l]]
            errors += 1
            print(f'  {k}  (thiếu ở: {", ".join(miss)})  {locs[0]}')
    else:
        print('  OK')

    # key truyền dưới dạng string literal (vd 'questionKey': 'chat_ai.x') nhưng chưa định nghĩa
    namespaces = {k.split('.')[0] for k in defined_all}
    maybe = {
        k: v for k, v in literals.items()
        if k.split('.')[0] in namespaces and k not in used
        and k.rsplit('.', 1)[-1] not in FILE_SUFFIXES
        and any(k not in langs[l] for l in names)
    }
    if maybe:
        print('  Có thể thiếu (string literal trùng namespace nhưng không có key):')
        for k, locs in sorted(maybe.items()):
            print(f'    {k}  {locs[0]}')

    print('\n== 3. Key định nghĩa nhưng không dùng (cân nhắc xóa) ==')
    defined = set().union(*[set(v) for v in langs.values()])
    unused = sorted(
        k for k in defined
        if k not in used and k not in literals
        and not any(k.startswith(p) for p in dynamic_prefixes)
    )
    for k in unused:
        print(f'  {k}')
    if not unused:
        print('  OK')
    else:
        print(f'  ({len(unused)} key; key ghép động theo prefix {sorted(dynamic_prefixes) or "[]"} đã được bỏ qua)')

    # 4. rỗng / placeholder
    print('\n== 4. Giá trị rỗng / placeholder không khớp ==')
    bad = 0
    for k in sorted(all_keys):
        vals = {l: langs[l].get(k) for l in names if k in langs[l]}
        for l, v in vals.items():
            if isinstance(v, str) and not v.strip():
                bad += 1
                print(f'  [{l}] rỗng: {k}')
        ph = {l: sorted(PLACEHOLDER.findall(v)) for l, v in vals.items() if isinstance(v, str)}
        if len({tuple(p) for p in ph.values()}) > 1:
            bad += 1
            print(f'  placeholder lệch: {k}  {ph}')
    errors += bad
    if not bad:
        print('  OK')

    if args.hardcoded:
        print('\n== 5. Text hard-code chưa dịch (ứng viên, cần xem tay) ==')
        n = 0
        for f in dart_files():
            rel = f.relative_to(ROOT)
            if 'environment' in rel.parts or 'data' in rel.parts[1:2]:
                continue
            for i, line in enumerate(f.read_text(encoding='utf-8').split('\n'), 1):
                s = line.strip()
                if s.startswith(('//', 'import ', 'export ')) or '.tr(' in line:
                    continue
                m = HARDCODED.search(line)
                if m:
                    n += 1
                    print(f'  {rel}:{i}  "{m.group(1)}"')
        print(f'  ({n} ứng viên)' if n else '  OK')

    print(f'\nTổng lỗi mức 1/2/4: {errors}')
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
