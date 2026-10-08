---
description: Fix a bug via plan → reproducing test → code → test → review (max 2 fix rounds)
argument-hint: "<bug description / file / repro steps>"
---

Bug to fix: `$ARGUMENTS`

If the description is too vague to locate the suspect area, ask once before starting.

Use the subagents `plan`, `code`, `test`, `review` (`.claude/agents/`) in the order below. Only `code` may edit source. Each agent ends with `AGENT_STATUS`; use it to decide the next step.

## 1. Plan — find the root cause
Ask `plan` to identify the root cause (not just the symptom), which layer causes the bug (UI/notifier/usecase/repository/datasource/mapper/BE schema), the minimal fix, and which test would reproduce the bug.

If `NEEDS_ORCHESTRATOR` (missing information, a decision is needed) → stop and ask the user.

## 2. Reproducing test (before fixing)
Ask `code` to write the smallest test that reproduces the bug following the project's test conventions (`.claude/rules/`), then ask `test` to run it and confirm the **test fails for the right reason**. If the bug is purely UI / cannot reasonably be tested, skip this step and say why.

## 3. Code — fix the bug
Ask `code` to fix it per `plan`'s plan: minimal change, no sprawling refactor, no new features.

## 4. Test
Ask `test`: the reproducing test must pass, then lint and run the full test suite (commands in the Commands section of `CLAUDE.md`).

## 5. Review
Ask `review` to go over the diff. For bugs touching sensitive areas (payment, auth, user data), request a closer check.

## Loop
- `FAIL` at step 4 or 5 → go back to `code` with a concrete list of errors, then re-run `test` + `review`.
- At most **2 rounds** back to `code`. Beyond that → stop and report the remainder to the user.

## Final report
- Root cause (1–2 sentences) and why the fix is in the right place.
- Files changed + tests added.
- `analyze`/`test` results; state clearly if any step was skipped.
- Remaining risks or things the user should check manually (e.g. run the app).

Do not commit; only commit when the user asks.
