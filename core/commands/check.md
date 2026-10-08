---
description: Format, lint and test the project, report errors concisely
---

Read the Commands section in `CLAUDE.md` to get the project's format, lint and test commands (if missing, ask the user, then propose adding them to `CLAUDE.md`).

Run in order: format → lint/analyze → test. Stop at the first serious failure.

Report:
- Each step: pass/fail.
- Lint errors: `file:line` + rule.
- Failing tests: test name + short message.
- Do not fix code on your own unless asked; only suggest how to fix.
