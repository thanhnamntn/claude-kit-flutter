---
paths:
  - "lib/features/**/pages/**"
  - "lib/features/**/notifiers/**"
  - "lib/features/**/state/**"
  - "lib/features/**/widgets/**"
---

# Presentation rules

- Pages are display-only: prefer `ConsumerWidget`. Use `ConsumerStatefulWidget` only when an `AnimationController` (vsync), `TextEditingController` or `ScrollController` is needed.
- Do not declare local state for logic in a Page (fetch flag, pagination index, loading flag) — keep it in the notifier/state.
- `ref.watch` variable names must be feature-specific (`homeState`, `ordersState`), never the generic `state`.
- State uses `sealed class`; substates are plain `class` (not `final class`, no `const` constructor needed). The UI uses an exhaustive `switch` so the compiler flags missing cases.
- A Notifier whose `build()` fetches data extracts the logic into `_fetch()`; `build()` only calls `_fetch()`. Refresh uses `state = _fetch()`.
- Features do not import `data/` (Model, DataSource, GraphQL): data flows through UseCase/provider and is an Entity.
- Notifiers do not call a DataSource directly — they go through a UseCase; handle results with `fold`.
- Notifier providers use `NotifierProvider.autoDispose`.
- Display strings go through the project's localization, with keys added for every supported language.
- Pages contain UI only: no file-level color/style constants or scattered `Color(0x...)` in pages/widgets. Use `AppColors` (`share/theme/app_colors.dart`) and `AppTheme`; add new colors there.
- A widget used by only one feature lives in `features/<feature>/widgets/`; move it to `share/widgets/` only when 2 or more features use it. `share/` contains no models, providers or business logic.
- Features do not import other features (exceptions: a shared app shell such as `shell`, or a common helper explicitly named in the project's rules).
- Do not call `.tr()` where it runs only once (route builder, file-level constants, state/notifier that stores ready-made strings) because changing the language will not update it. Pass keys and translate in `build()`; change language through a helper that rebuilds the whole widget tree rather than just calling `context.setLocale`.
