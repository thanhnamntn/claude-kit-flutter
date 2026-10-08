#!/usr/bin/env python3
"""Check the translations of a Flutter project (easy_localization).

Usage (from the project root):
  python3 .claude/skills/check-translations/scripts/check_translations.py [--hardcoded]

Checks:
  1. Keys present in one language but missing in another.
  2. Keys used in code (`'a.b'.tr(`, `tr('a.b'`, `plural('a.b'`) that do not exist.
  3. Keys defined but unused (keys that may be built dynamically are skipped).
  4. Empty values, and `{}` / `{name}` placeholders that differ between languages.
  5. (--hardcoded) Hard-coded display text in Text('...') / label / hint... that is untranslated.
Exit code 1 if there are errors at level 1, 2 or 4.
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
        print(f'Fewer than 2 translation files found in {TRANS_DIR}')
        return 1
    langs = {f.stem: flatten(json.loads(f.read_text(encoding='utf-8'))) for f in files}
    names = list(langs)
    errors = 0

    # 1. keys missing between languages
    print('== 1. Keys missing between languages ==')
    all_keys = set().union(*[set(v) for v in langs.values()])
    for lang, keys in langs.items():
        missing = sorted(all_keys - set(keys))
        if missing:
            errors += len(missing)
            print(f'  [{lang}] missing {len(missing)} keys:')
            for k in missing:
                print(f'    - {k}')
    if all(not (all_keys - set(k)) for k in langs.values()):
        print('  OK')

    # 2/3. keys used in code
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
    print('\n== 2. Keys used in code but not defined ==')
    undefined = {k: v for k, v in used.items() if any(k not in langs[l] for l in names)}
    if undefined:
        for k, locs in sorted(undefined.items()):
            miss = [l for l in names if k not in langs[l]]
            errors += 1
            print(f'  {k}  (missing in: {", ".join(miss)})  {locs[0]}')
    else:
        print('  OK')

    # keys passed as string literals (e.g. 'questionKey': 'chat_ai.x') but not defined
    namespaces = {k.split('.')[0] for k in defined_all}
    maybe = {
        k: v for k, v in literals.items()
        if k.split('.')[0] in namespaces and k not in used
        and k.rsplit('.', 1)[-1] not in FILE_SUFFIXES
        and any(k not in langs[l] for l in names)
    }
    if maybe:
        print('  Possibly missing (string literal matches a namespace but has no key):')
        for k, locs in sorted(maybe.items()):
            print(f'    {k}  {locs[0]}')

    print('\n== 3. Keys defined but unused (consider removing) ==')
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
        print(f'  ({len(unused)} keys; dynamically built keys with prefixes {sorted(dynamic_prefixes) or "[]"} were skipped)')

    # 4. empty / placeholder
    print('\n== 4. Empty values / mismatched placeholders ==')
    bad = 0
    for k in sorted(all_keys):
        vals = {l: langs[l].get(k) for l in names if k in langs[l]}
        for l, v in vals.items():
            if isinstance(v, str) and not v.strip():
                bad += 1
                print(f'  [{l}] empty: {k}')
        ph = {l: sorted(PLACEHOLDER.findall(v)) for l, v in vals.items() if isinstance(v, str)}
        if len({tuple(p) for p in ph.values()}) > 1:
            bad += 1
            print(f'  placeholder mismatch: {k}  {ph}')
    errors += bad
    if not bad:
        print('  OK')

    if args.hardcoded:
        print('\n== 5. Hard-coded untranslated text (candidates, review manually) ==')
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
        print(f'  ({n} candidates)' if n else '  OK')

    print(f'\nTotal errors at level 1/2/4: {errors}')
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
