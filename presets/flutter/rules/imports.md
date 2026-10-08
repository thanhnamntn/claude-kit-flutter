# Import & barrel rules

This rule has no `paths:`, so it is always loaded.

- Every folder with 3 or more `.dart` files must have an `index.dart` (barrel) exporting all files in the folder: `library;` then `export 'xxx.dart';` lines in alphabetical order.
- For folders that have a barrel: import via `index.dart` instead of individual files, to reduce the number of import lines:
  `import 'package:<app>/domain/entities/index.dart';`
- When adding or removing a file in a folder with a barrel, update `index.dart` at the same time.
- A file inside the barrel's own folder imports sibling files directly, not through its own folder's `index.dart`.
- Always use `package:` imports; order imports per `directives_ordering` (run `dart fix --apply --code=directives_ordering` if needed).
- The list of folders with barrels: enumerate per project.
- Dependency direction (no reverse imports): `features → domain`; `data → domain`; `core/providers` connects `data` + `domain`; `share → domain/core` (does not import `features/`); `domain` does not import `data/`, `share/`, `features/`; `features` does not import `data/` (get data via UseCase/provider); `data` does not import `share/`, `features/`.
