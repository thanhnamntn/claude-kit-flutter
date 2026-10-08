---
name: check-translations
description: Check all of the project's translations (easy_localization) — keys missing between en/vi, keys used in code but not defined, unused keys, mismatched placeholders, untranslated hard-coded text. Use when adding/editing display strings, before creating a PR, or when the user says "check translate/i18n/translations".
argument-hint: "[--fix | empty = report only]"
---

# Check translations

Translations live in `assets/translations/{en,vi}.json`; code uses `'a.b.c'.tr()` (`easy_localization`). Convention: every display string goes through `.tr()` and has a key in **every** supported language.

## 1. Run the check

```bash
python3 .claude/skills/check-translations/scripts/check_translations.py --hardcoded
```

The script (does not modify files) reports 5 groups:

1. Keys missing between languages (present in `en` but not in `vi`, or vice versa).
2. Keys used in code (`'x.y'.tr(`, `tr('x.y'`, string literals passed like `'questionKey': 'x.y'`) but not defined.
3. Keys defined but not seen in use. Dynamically built keys (`'prefix.$var'`) are skipped by prefix; **always verify manually before deleting** since a key may be built another way.
4. Empty values, or placeholders (`{}`, `{name}`) that differ between languages.
5. (`--hardcoded`) Hard-coded text in `Text('...')`, `label:`, `hint:`, `title:`... that is untranslated — candidates only.

Exit code `1` when there are errors in group 1, 2 or 4.

## 2. Classify the results

- **Must fix** (groups 1, 2, 4): missing keys, nonexistent keys, mismatched placeholders.
- **Worth a look** (group 3): unused keys — propose deletion but do not delete on your own.
- **Needs judgment** (group 5): ignore input placeholder examples (`DD/MM/YYYY`, `hello@example.com`), language names ("English", "Tiếng Việt"), proper nouns/brands, technical formats. Only report strings users actually read.

## 3. Report

Present concisely:
- Must-fix errors: `key` — issue — `file:line` (if available).
- Suggested translations for missing keys (EN ↔ VI), matching the tone of nearby keys.
- The number of unused keys and the largest groups (by namespace) so the user can decide on cleanup.
- Hard-coded strings worth translating, with suggested keys under the screen's namespace.

## 4. Fix (only when the user asks or it is called with `--fix`)

- Add keys to **both** files, keeping the nested structure and placing them near related keys; keep the 4-space indent used by the existing files.
- Hard-coded text → replace with `'<namespace>.<key>'.tr()` (use `args:` for dynamic values), without changing the layout.
- Do not delete unused keys without confirmation.
- Re-run the script and make sure groups 1, 2, 4 are clean; then `dart format .` and `flutter analyze`.

## Notes

- Keys shared across many screens go under `common.*`.
- Do not concatenate strings with `+`; use placeholders in the translation so word order can be translated.
- The script only reads `lib/` and `assets/translations/`; run it from the project root.
