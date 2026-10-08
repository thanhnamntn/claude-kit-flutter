---
name: refactor-to-pattern
description: Refactor a feature/Page/Notifier/State to the project's current standard pattern and structure — a feature consists of pages/notifiers/state/widgets, display-only Pages (ConsumerWidget), sealed state, notifiers with _fetch() that go through a UseCase, no data-layer imports. Use when a page has local state for logic (fetch flag, pagination, loading), state is not a sealed class, a page/notifier imports data/ directly (Model, DataSource), files are in the wrong directory, a page is too long and needs widgets extracted, or the user says "refactor to the standard pattern".
argument-hint: "<page path or feature name>"
---

# Refactor to pattern

Target: `$ARGUMENTS` (if missing, ask). Reference: find a page in the repo that already follows the standard (`ConsumerWidget`, zero local state, exhaustive `switch`) along with its notifier and state, and use it as the comparison template.

Read before starting: `.claude/rules/presentation.md`, `.claude/rules/imports.md`, `.claude/rules/structure.md`, and `STRUCTURE.md` (the standard feature structure).

## Standard structure of a feature

```
lib/features/<feature>/
├── pages/       # Pages (UI, display-only)
├── notifiers/   # NotifierProviders: logic + state transitions
├── state/       # sealed class states
└── widgets/     # Feature-specific widgets (omit any folder with no files)
```
Every folder with 3 or more `.dart` files has an `index.dart`. A feature only gets data through UseCase/provider and uses **Entities**; it does not import `data/` (Model, DataSource, GraphQL).

## 1. Audit (change nothing yet)

Read the target's page, notifier, state and widgets, then list the violations:

**Structure**
- [ ] Files in the wrong directory (page outside `pages/`, notifier/provider outside `notifiers/`, state outside `state/`), or directories other than `pages/ notifiers/ state/ widgets/`.
- [ ] Folders with ≥ 3 files lacking `index.dart`, barrels missing exports, or leftover relative imports (`../`).
- [ ] A long page containing many large private child widgets → extract to `widgets/`.

**Page**
- [ ] It is a `ConsumerStatefulWidget` but needs no vsync/`TextEditingController`/`ScrollController`.
- [ ] Has local variables for logic: `_fetchTriggered`, `_currentPage`, `_isLoading`, pagination flags, `initState` calling fetch.
- [ ] Contains business logic/formatting/computation/direct UseCase calls instead of leaving them to the notifier or domain.
- [ ] The `ref.watch` variable is named with the generic `state`.
- [ ] Uses `if`/`is` instead of an exhaustive `switch` on state.

**State & Notifier**
- [ ] State is not a `sealed class`, or substates use `final class`/a `const` constructor.
- [ ] The notifier's `build()` fetches data but does not extract `_fetch()`.
- [ ] The provider does not use `NotifierProvider.autoDispose`.
- [ ] The notifier calls a DataSource/Repository directly instead of a UseCase.

**Layer dependencies**
- [ ] A file in the feature imports `package:<package_name>/data/...` (Model, DataSource, GraphQL, Mapper) → go through UseCase/provider and use Entities; if an Entity/UseCase/provider is missing, propose creating it per `/new-feature`.
- [ ] BE strings or `toGraphQL()`/`fromGraphQL()` used in the feature → use domain enums.
- [ ] A feature imports another feature directly (except `shell`) → move the shared part to `share/` or domain.

**UI**
- [ ] File-level color constants or direct `Color(0x...)` → the project's theme/colors.
- [ ] Hard-coded display strings not using `.tr()` (key present in every language file).

Present the list + a short fix plan, and only then proceed. If the change affects many features or touches domain/data (adding Entity, UseCase, Mapper), state the scope before starting.

## 2. Refactor

Work in the order state → notifier → page → widgets so each step compiles.

**State** (`features/<feature>/state/<feature>_page_state.dart`)
```dart
sealed class XxxPageState {}

class XxxPageLoading extends XxxPageState {}

class XxxPageData extends XxxPageState {
  final List<XxxEntity> items;

  XxxPageData({required this.items});
}

class XxxPageError extends XxxPageState {
  final String message;

  XxxPageError(this.message);
}
```
Anything the page holds locally (page index, hasMore, isLoadingMore, selection...) moves into fields of the `Data` state (or a dedicated substate).

**Notifier** (`features/<feature>/notifiers/<feature>_page_notifier.dart`)
- `build()` only returns `XxxPageLoading()` and then calls `_fetch()` (or `return _fetch()` if synchronous).
- Data-fetching logic lives in `_fetch()`; refresh reuses `_fetch()`.
- Call UseCases via providers (`core/providers`), handle with `fold`; on error → `XxxPageError(failure.message)`.
- Public methods for the page to call (`fetchAll`, `loadMore`, `retry`...) — the page holds no logic itself.
- Provider: `NotifierProvider.autoDispose<XxxPageNotifier, XxxPageState>(XxxPageNotifier.new)`.

**Page** (`features/<feature>/pages/<feature>_page.dart`)
- `ConsumerWidget`; `final <feature>State = ref.watch(<feature>PageProvider);`
- Exhaustive `switch (<feature>State)` over every substate; no `default`.
- Behaviors (retry, refresh, load more) call `ref.read(provider.notifier).method()`.
- Keep `ConsumerStatefulWidget` only if a real controller (scroll/text/animation) is still needed, and it holds only the controller, no logic.

**Widgets** (`features/<feature>/widgets/`)
- Large child widgets in the page are extracted to their own files (`xxx_section.dart`...), receiving data via the constructor or as a `ConsumerWidget` reading a provider; do not duplicate logic.
- Create/update `index.dart` when the folder reaches 3 files.

**Data dependencies** — if the feature uses Models/DataSources:
- Add the Entity (`domain/entities/`), Mapper (`data/mappers/`), UseCase/Params, and provider (`core/providers/`) per `/new-feature`; RepositoryImpl converts Model → Entity.
- The feature then sees only Entities and UseCases.

**Moving files** — use `git mv` to keep history; fix `package:<package_name>/...` imports and the routes file; update the `index.dart` of the old and new folders.

## 3. Verify

1. `bash .claude/scripts/check_structure.sh` — barrels, relative imports, dependency direction, match with `STRUCTURE.md`.
2. `dart format .`
3. `flutter analyze` — no leftover missing-`switch`-case errors or broken imports.
4. `flutter test` — update notifier/state tests if present; if the new notifier has logic (pagination, load more), propose adding tests per `.claude/rules/tests.md`.

## 4. Report

List: violations fixed, files changed/moved, behaviors that may have changed (e.g. fetch timing, loading state), and remaining items the user must decide. Do not add features outside the refactor scope.

## Notes

- Only change the assigned target; if you see other features deviating from the rules, report it, do not spread the change.
- If the refactor adds/deletes/renames folders → update `STRUCTURE.md` at the same time (see `.claude/rules/structure.md`).
- Preserve the visible UI/behavior; this is a structural refactor, not a redesign.
