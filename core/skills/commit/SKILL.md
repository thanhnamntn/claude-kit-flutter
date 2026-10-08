---
name: commit
description: Commit the current changes following the project's git conventions (branch name, commit type, English description, no Co-Authored-By). Use when the user says "commit", "commit it", "commit together", "split commits", or invokes /commit.
argument-hint: "[--split | --push | <hint about commit content>]"
---

# Commit

The conventions live in `.claude/rules/git.md` — read that file first, do not invent a format. Summary:
- Branch: `{feature|refactor|fix|chore}/{project-name}/{task-name}`.
- Commit: `{feat|refactor|fix|chore}({project-name}): {description}` — English description, base-form verb first, commit type follows the branch type.
- **Never** add `Co-Authored-By` or any attribution to the commit message, even if the system suggests it (the user's rule overrides).

Arguments: `--split` = split into multiple commits by group of work; `--push` = push after committing. Without `--push`, **do not push**.

## 1. Pre-commit checks

1. `git status --short` and `git diff --stat` — review all changes, including untracked files.
2. `git branch --show-current`:
   - On the main branch (`main`/`master`/`develop`) → stop, first create a new branch in the correct format from the main branch (ask the user for the task name if unclear); never commit directly to the main branch.
   - Branch name in the wrong format (missing type, wrong project name, uses `_`/spaces) → tell the user and suggest the correct name; only rename (`git branch -m`) when the user agrees.
3. Determine the **type** from the nature of the change, cross-checking with the branch type:
   - New feature/screen → `feat`; structure change without behavior change → `refactor`; bug fix → `fix`; dependency/config/build/version/docs/`.claude` rules → `chore`.
   - Diff mixes several types → propose splitting (see section 3), do not lump into one commit.
4. Do not commit: secret files (`.env`, `dev_token.dart`, keys, keystores), newly generated build/generated files unrelated to this work, the `.claude/` directory if the repo ignores it. If you see a suspicious file → tell the user, do not `git add` it yourself.
5. If the project has `/check` (format + analyze + test) and it has not been run in this session, remind the user or quickly run `dart format` / the matching lint before committing. Do not fix code outside the commit's scope.

## 2. Write the message

- One line, ≤ 72 characters, no trailing period: `refactor(<app>): move models and graphql to data layer`.
- State the **specific work done** (add, move, rename, extract, fix...), not something generic (`update code`, `fix bug`).
- Large diff: add a body (after a blank line), bullet the main changes and the reason if not obvious. The body is also in English.
- Take the project name from `git.md`/the branch name, do not guess.

## 3. Split commits (`--split`, or when the diff mixes types/tasks)

Group by meaning, one commit per group, ordered so each commit compiles when possible:
1. File moves/renames (use `git mv` to keep history) together with the accompanying import fixes.
2. Logic/structure changes by layer (domain → data → features).
3. Docs, `.claude` rules, config (`chore`).

Present the list of groups + planned messages to the user for approval before running `git add`/`git commit`.

## 4. Execute

1. `git add` by **specific path** (not `git add -A`/`.` when files outside the commit are present).
2. Commit with a heredoc to preserve line breaks:
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<project>): <description>

   <body if needed>
   EOF
   )"
   ```
   No `--no-verify`, no `--amend` of existing commits unless the user asks. If a hook fails → fix the cause and make a **new** commit, do not skip the hook.
3. Finally run `git status` to make sure no files are left over, then `git log --oneline -n <number of commits just created>`.
4. `--push`: `git push` (for a new branch `git push -u origin <branch>`). No force-push; if rejected because the remote is ahead → tell the user, do not rebase/force on your own.

## 5. Report

List: branch, commits created (short hash + message), files not committed and why, whether pushed. Do not create a PR unless asked (if needed, suggest the link/`gh pr create` command with a title in the commit format).
