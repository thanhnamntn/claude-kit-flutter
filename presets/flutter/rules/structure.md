---
paths:
  - "lib/**"
  - "STRUCTURE.md"
---

# Structure rules

`STRUCTURE.md` is the source of truth for the `lib/` directory tree. Any change to the directory tree must update `STRUCTURE.md` **in the same commit**.

- Update when: adding, deleting, renaming or moving a **folder** in `lib/`; adding/deleting/renaming structural-level files (files in `environment/`, the `lib/` root, base classes); changing a folder's role.
- Not needed when only adding/editing/deleting ordinary files in existing folders (page, notifier, entity, mapper...).
- New feature: use exactly the 4 folders `pages/ notifiers/ state/ widgets/` (omit any folder with no files); `STRUCTURE.md` only describes the template feature `<feature>`, not each feature.
- A new folder with 3 or more `.dart` files: add an `index.dart` (see `imports.md`).
- After updating, run `bash .claude/scripts/check_structure.sh` (or `/check`); the script reports mismatches between `STRUCTURE.md` and the real directories, missing barrels, relative imports, and dependency direction.
- When a structure change affects many projects (a change to a shared convention), also update the template in `claude-kit/presets/flutter/STRUCTURE.md`.
