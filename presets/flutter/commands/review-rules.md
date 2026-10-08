---
description: Review the current diff against the project's [manual] rules
argument-hint: "[branch | file | empty = current git diff]"
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Read, Grep
---

Review the changes `$ARGUMENTS` (default: `git diff` plus untracked files of the current branch against `main`). Read-only, never edit files.

Read `CLAUDE.md` and `.claude/rules/`, then check the rules that `flutter analyze` does NOT catch:

**Architecture**
- Entities do not import Models; mapping happens only in `RepositoryImpl` via `XxxMapper.toEntity`; Mappers have `._()` + static methods.
- Entity classes have the `Entity` suffix and live in `domain/entities/`.
- Provider chain `dataSource → repository → useCase → notifier`; notifiers do not call DataSources directly.
- Dependency direction: `domain` does not import `data/`, `share/`, `features/`; `features` does not import `data/`; `share` does not import `features/`; `data` does not import `share/`/`features/`. Run `bash .claude/scripts/check_structure.sh`.
- The domain layer does not import Flutter.
- BE strings (`toGraphQL`/`fromGraphQL`) are used only in `data/`.
- Directory tree changed → `STRUCTURE.md` has been updated.

**Code conventions**
- Repository: field `remoteDataSource`, try/catch → `Either`, streams use `StreamTransformer.fromHandlers`; no raw `throw`.
- Method order: list → batchGet → get → create → update → delete → domain-specific.

**Presentation**
- State is a `sealed class`, substates use plain `class`; UI uses an exhaustive `switch`.
- Notifiers have a dedicated `_fetch()`; `build()` only calls it.
- Pages are display-only: no local state for logic (flags, pagination); use `ConsumerStatefulWidget` only when a controller/vsync is needed.
- `ref.watch` variables are not given the generic name `state`.

**Other**
- Display strings use the project's localization, with keys present in every supported language.
- Change needs a release → `version:` in `pubspec.yaml` (was the BUILD number bumped?).
- Missing tests for new usecases/mappers/repositories/notifiers (`.claude/rules/tests.md`).

Output: a list of violations ordered by severity (high → low), each as `file:line` + violated rule + short fix suggestion. If there are no violations, say it is clean.
