# Git branch & commit rules

This rule has no `paths:`, so it is always loaded.

## Branch names

```
{type}/{project-name}/{task-name}
```

| Type | Use when | Example |
|---|---|---|
| `feature` | Adding a new feature/screen | `feature/my-app/build-ui-member` |
| `refactor` | Changing code structure without changing behavior | `refactor/my-app/move-data-domain-out-of-core` |
| `fix` | Fixing a bug | `fix/my-app/payment-webview-polling` |
| `chore` | Chores that do not change runtime code: dependency updates, config, build/version, docs, `.claude` rules | `chore/my-app/update-build-version` |

- `{project-name}`: the project name, lowercase, joined with `-` (taken from the repo/package name).
- `{task-name}`: describes the work, lowercase, words joined with `-`, no accents, no spaces or `_`.
- Pick the type by the nature of the work; one type per branch. Work that mixes fix and refactor (or chore) must be split into separate branches/commits.
- Always name new branches with the format above.
- New branches are **always created from `main`**, which must be updated first: `git checkout main` → `git pull --rebase origin main` → only then `git checkout -b <branch>`. Never create a branch from another working branch (unless the user explicitly says so). If there are uncommitted changes, stop and tell the user; do not stash on your own.

## Commit message

```
{type}({project-name}): {work related to the commit}
```

| Type | Use when | Example |
|---|---|---|
| `feat` | New feature | `feat(my-app): add member profile page` |
| `refactor` | Structure change, no behavior change | `refactor(my-app): move beverage logic to notifiers` |
| `fix` | Bug fix | `fix(my-app): stop polling after payment completed` |
| `chore` | Dependency, config, build/version, docs, `.claude` rules | `chore(my-app): bump version to 1.0.2+3` |

- The commit type follows the branch type: `feature` branch → `feat`, `refactor` branch → `refactor`, `fix` branch → `fix`, `chore` branch → `chore`.
- `{project-name}` is the same as the project name in the branch name.
- Description: English, concise, starting with a base-form verb (add, update, move, fix...), stating the specific work of that commit.
- Do not add a `Co-Authored-By` line (or any attribution) to commit messages.
