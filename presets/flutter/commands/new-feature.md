---
description: Scaffold a new feature following Clean Architecture (domain → data → presentation)
argument-hint: "<feature_name> [entity_name]"
---

Create the new feature `$ARGUMENTS` (snake_case for files, PascalCase for classes). If the name is missing, ask.

Before creating anything, read `CLAUDE.md`, `.claude/rules/` and `STRUCTURE.md` (if present), then open the nearest complete feature in the repo as a template to mimic its directory layout and naming exactly. The paths below are the default layout — if the project differs, follow the project. Do not invent APIs/routes/endpoints; if a new query or endpoint is needed, ask the user.

## Domain (`lib/domain/`)
- `entities/<name>_entity.dart` — class with the `Entity` suffix, does not import Models.
- `datasources/<name>_datasource.dart` — abstract interface, returns `XxxModel`.
- `repositories/<name>_repository.dart` — abstract, returns `Either<Failure, XxxEntity>`.
- `usecases/<verb>_<name>_usecase.dart` — `XxxParams extends Equatable` + `UseCase`, verb per the Naming section in `.claude/rules/data-layer.md`.
- `models/<name>_model.dart` — only `fromJson`/`toJson`; export via `index.dart` if the directory has a barrel.

## Data (`lib/data/`)
- `mappers/<name>_mapper.dart` — private constructor `._()`, static `toEntity(model)`.
- `datasources/<name>_datasource_impl.dart` — impl that calls the API (GraphQL/REST).
- `repositories/<name>_repository_impl.dart` — field `remoteDataSource`, try/catch → `Right(mapped)` / `Left(ServerFailure(e.toString()))`.

## Providers (`lib/core/providers/`)
One provider per file, then add an `export` to `lib/core/providers/index.dart`:
- `datasource/<name>_data_source_provider.dart`
- `repository/<name>_repository_provider.dart`
- `usecase/<verb>_<name>_usecase_provider.dart`

## Presentation (`lib/features/<feature>/`)
- `state/<feature>_page_state.dart` — `sealed class` + plain `class` substates (Loading / Data / Error).
- `notifiers/<feature>_page_notifier.dart` — `Notifier` + `NotifierProvider.autoDispose`; `build()` only `return _fetch()` (or sets Loading then calls `_fetch`), logic lives in `_fetch()`; handle results with `fold`.
- `pages/<feature>_page.dart` — display-only `ConsumerWidget`, exhaustive `switch` on state, specific watch variable names (e.g. `<feature>State`), no local state logic.
- `widgets/` — feature-specific widgets (create the directory when needed).

## General rules
- Import `package:<package_name>/...`, single quotes, trailing commas, `required` params first.
- No raw exceptions; use `Either<Failure, T>`.
- Do not add a route/mock datasource unless the user asks (if adding a route, edit the project's routes file).

Finally run `dart format .` and `flutter analyze`, then list the files created and the remaining work (route, query/endpoint, localization keys).

If the new feature/folder changes the directory tree: update `STRUCTURE.md` and run `bash .claude/scripts/check_structure.sh` (see `.claude/rules/structure.md`).
