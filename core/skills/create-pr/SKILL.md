---
name: create-pr
description: Create a Pull Request into main. Always update main (pull --rebase), then return to the working branch and rebase it onto main before pushing and opening the PR. Use when the user says "create PR", "open PR", "push for review", or invokes /create-pr.
argument-hint: "[--draft | <notes for the PR description>]"
---

# Create PR

Branch/commit conventions are in `.claude/rules/git.md`. The target branch is **always `main`** (if the repo uses another name, get it from `git symbolic-ref --short refs/remotes/origin/HEAD`, dropping `origin/`). `--draft` = open the PR as a draft.

Mandatory order — **steps 2–4 must not be skipped even if the branch looks up to date**: go to main → pull --rebase → return to the working branch → rebase onto main → only then push/create the PR.

## 1. Prepare

1. `git branch --show-current` → remember as `<branch>`. If on `main`/`master` → stop, do not create a PR from the main branch.
2. The branch name must be `{feature|refactor|fix|chore}/{project-name}/{task-name}`; if wrong, tell the user (do not rename it yourself).
3. `git status --short`: uncommitted changes remain → stop, suggest running `/commit` first. Do not stash, do not skip.
4. `git log main..HEAD --oneline` (only accurate after step 2) must show at least 1 commit, otherwise report "nothing to create a PR for".
5. `git fetch origin --prune`.

## 2. Update main

```bash
git checkout main
git pull --rebase origin main
```
- Local `main` has its own unpushed commits (differs from `origin/main`) → stop and tell the user, do not handle it yourself.
- Pull error/conflict → stop, report the cause. No `--force`, no `reset --hard`.

## 3. Return to the working branch

```bash
git checkout <branch>
```

## 4. Rebase the current branch onto main (rebase current changes onto main)

While on `<branch>`, place this branch's commits on top of the latest `main`:
```bash
git rebase main
```
The rebase direction is **working branch → onto main**; do not rebase `main` onto the branch, do not merge `main` into the branch, do not `git pull` into the working branch.
- On conflicts: list the conflicted files (`git status`), read both sides and resolve **only when the intent is clear and both sides can be kept**; after each file `git add <file>` then `git rebase --continue`. If the intent is unclear → `git rebase --abort`, report each file and the two options to the user, and wait for their decision.
- Do not use `-X ours/theirs` or `--skip` to get past conflicts.
- After the rebase, run a quick check if the project has one (`/check` or at minimum `flutter analyze` + `flutter test`). If it fails due to changes from main → tell the user before pushing.

## 5. Push

1. Check whether the branch already exists on the remote: `git ls-remote --heads origin <branch>`.
   - Not there → `git push -u origin <branch>`.
   - There, and the rebase did **not change** already-pushed history (`git status` says up to date / only ahead) → `git push`.
   - There, but the rebase rewrote commits (reports diverged) → needs `git push --force-with-lease origin <branch>`. **Ask the user to confirm first** (state the branch name and the number of commits that will be overwritten), run only on this branch, never on `main`, never bare `--force`.
2. Push rejected for another reason → tell the user, do not handle it yourself.

## 6. Create the PR

Use `gh pr create --base main --head <branch>`; first run `gh pr view <branch>` — if an open PR already exists, do not create a new one, just give the user that PR's link (pushing more commits updates the PR automatically).

- **Title**: in commit format — `{type}({project-name}): {English description}`. For a single commit use that message; for several commits write one summarizing line by branch type.
- **Body** (English, concise; add the user's notes if any):
  ```
  ## Summary
  - <main changes, 2–5 bullets>

  ## Changes
  - <group by layer/feature if the diff is large>

  ## Test plan
  - [ ] flutter analyze
  - [ ] flutter test
  - [ ] <screens/flows to test manually>
  ```
  Base it on `git log main..HEAD` and `git diff main...HEAD --stat`, do not invent changes. Tick items that were actually run in this session, leave the rest unticked.
- Do not add attribution lines (Co-Authored-By, "Generated with...") to the body, same as the commit rule.
- Heredoc for the body:
  ```bash
  gh pr create --base main --head <branch> --title "<title>" --body "$(cat <<'EOF'
  ...
  EOF
  )"
  ```

## 7. Report

List: result of pulling main (any new commits), rebase (number of commits, any conflicts, how they were resolved), push (normal or force-with-lease), PR link, and what the user needs to do next (reviewers, manual testing). Do not merge the PR yourself, do not assign reviewers yourself.
