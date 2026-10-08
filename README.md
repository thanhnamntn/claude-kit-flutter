# claude-kit-flutter

A reusable `.claude/` setup for [Claude Code](https://claude.com/claude-code), with a Flutter preset (Clean Architecture + Riverpod). One command installs agents, slash commands, skills and rules into your project; you then adjust a few project-specific things.

## What's inside

```
claude-kit-flutter/
├── install.sh
├── core/                          # stack-independent
│   ├── agents/                    # plan, code, review, test (each ends with AGENT_STATUS)
│   ├── commands/                  # check, fix-bug, review-rules
│   ├── skills/
│   │   ├── commit/                # conventional commits, --split / --push
│   │   └── create-pr/             # pull --rebase main -> rebase your branch onto main -> push -> open PR
│   ├── rules/git.md               # branch and commit naming, new branches always from updated main
│   ├── settings.json              # read-only git permissions
│   └── CLAUDE.md.template
└── presets/flutter/               # Clean Architecture + Riverpod
    ├── rules/                     # presentation, domain-entities, data-layer, imports, structure, tests
    ├── commands/                  # check, review-rules, new-feature (override core)
    ├── skills/                    # refactor-to-pattern, check-translations
    ├── scripts/check_structure.sh # barrels, relative imports, dependency direction, STRUCTURE.md drift
    ├── STRUCTURE.md               # sample lib/ tree (moved to project root on install)
    └── CLAUDE.md.fragment
```

## Install

```bash
git clone https://github.com/thanhnamntn/claude-kit-flutter.git
cd claude-kit-flutter
./install.sh ~/path/to/project --preset flutter   # core + Flutter preset
./install.sh ~/path/to/project                    # core only
./install.sh ~/path/to/project --force            # overwrite existing files
```

- Existing files are never overwritten (unless `--force`); preset files you have customized are kept too.
- `CLAUDE.md` is never overwritten: if it exists, the template is written to `CLAUDE.md.kit-new` for you to merge.
- `STRUCTURE.md` is moved to the project root; `check_structure.sh` lives in `.claude/scripts/`.

## After installing

1. **Git:** in `.claude/rules/git.md`, `skills/commit` and `skills/create-pr`, replace `<app>` / `{project-name}` with your project name.
2. **`CLAUDE.md`:** fill in the overview, **Commands** (the `test` agent and `/check` read them) and architecture.
3. **`paths:` in `.claude/rules/*.md`:** adjust to your real folders.
4. **Flutter preset** assumes `lib/{core,data,domain,features,share}` and features made of `pages/ notifiers/ state/ widgets/`. For a different layout, edit `STRUCTURE.md` and `scripts/check_structure.sh`.
5. **`.claude/settings.json`:** add the Bash permissions you need (e.g. `Bash(flutter *)`, `Bash(dart *)`).
6. Add project-specific rules (payments, APIs, ...) under `.claude/rules/`.
7. Run `bash .claude/scripts/check_structure.sh` to see where the project deviates.

## Conventions

- New branches are always created from `main` after `git checkout main && git pull --rebase origin main`.
- `/create-pr` rebases your working branch onto `main` (`git rebase main`); it never merges `main` into the branch, and uses `--force-with-lease` only after you confirm.
- Commits carry no `Co-Authored-By`; commit and PR text is in English; code comments are in English.
- Changing the folder tree means updating `STRUCTURE.md` in the same commit.

## License

[MIT](LICENSE)
