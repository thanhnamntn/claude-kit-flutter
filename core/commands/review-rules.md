---
description: Review the current diff against the project's rules (.claude/rules + CLAUDE.md)
argument-hint: "[branch | file | empty = diff against the main branch]"
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Read, Grep
---

Review the changes `$ARGUMENTS` (default: `git diff` plus untracked files of the current branch against the main branch). Read-only, never edit files.

1. Read `CLAUDE.md` and the files in `.claude/rules/` matching the changed files.
2. For each rule, check whether the diff violates it — only what linters do NOT catch (architecture, layering, naming/location conventions, error handling, display strings/i18n, missing tests).
3. If the change needs a release, check the project's versioning rules (if any).

Output: a list of violations ordered by severity (high → low), each as `file:line` + violated rule + short fix suggestion. If there are no violations, say it is clean.
