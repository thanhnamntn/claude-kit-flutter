---
description: Format, analyze and test the project, report errors concisely
allowed-tools: Bash(bash .claude/scripts/check_structure.sh:*), Bash(dart format:*), Bash(flutter analyze:*), Bash(flutter test:*)
---

Run in order from the project root, stopping at the first serious failure:

1. `bash .claude/scripts/check_structure.sh` (structure: barrels, imports, dependency direction, match with STRUCTURE.md)
2. `dart format .`
3. `flutter analyze`
4. `flutter test`

Report:
- Each step: pass/fail.
- For analyze errors/warnings: list `file:line` + rule (rules in `analysis_options.yaml`).
- For failing tests: test name + short message.
- Do not fix code on your own unless asked; only suggest how to fix.
