---
paths:
  - "lib/data/**"
  - "lib/core/providers/**"
---

# Data layer & providers rules

- Mapper: private constructor `._()`, static `toEntity(model)` methods only. Model → Entity mapping happens in `RepositoryImpl`.
- RepositoryImpl: the injected field is named `remoteDataSource`; `try/catch` → `Right(...)` / `Left(ServerFailure(e.toString()))`; void uses `Right(null)`.
- Streams do not use try/catch: `.map(Right)` + `.transform(StreamTransformer.fromHandlers(...))` (needs `import 'dart:async'`).
- The DataSource interface lives in `data/datasources/` next to its impl (returns Model); the domain does not know Models. BE strings of enums (`toGraphQL`/`fromGraphQL`) live in `data/mappers/enum_graphql_mapper.dart`.
- A DataSource impl only calls the API (GraphQL/HTTP) and contains no business logic. Local/mock datasources are not deleted.
- Provider chain: `dataSource → repository → useCase → notifier`. One provider per file, placed per the project's layout (see `STRUCTURE.md`/`CLAUDE.md`); if a barrel `index.dart` exists, new providers must be exported from it.
- Method order within a class: list → batchGet → get → create → update → delete → domain-specific.
- Named params: `required` before optional.

## Naming

| Verb | When | Example |
|---|---|---|
| `list` | Fetch many items | `listBeverages()` |
| `get` | Fetch one item by ID | `getTransaction(id)` |
| `batchGet` | Fetch many items by a list of IDs | `batchGetCombos(ids)` |
| `create` / `update` / `delete` | CRUD | `createTransaction()` |
| `cancel` / `complete` | Change domain state | `cancelTransaction()` |

- Files: `snake_case.dart`; interface `xxx.dart` + implementation `xxx_impl.dart`.
- DataSource impls are named after the data source: `xxx_datasource_impl.dart` (real source), `xxx_mock_datasource_impl.dart` (mock), `xxx_hardcoded_datasource_impl.dart` (data hardcoded in the app); do not use the generic name `_local_`.
- Barrel files are always named `index.dart`.

## Streams in a Repository

Streams cannot use try/catch — wrap errors with `StreamTransformer.fromHandlers`:

```dart
return remoteDataSource
    .streamXxx(params: params)
    .map((data) => Right<Failure, XxxModel>(data))
    .transform(
      StreamTransformer.fromHandlers(
        handleError: (error, stackTrace, sink) {
          sink.add(Left<Failure, XxxModel>(ServerFailure(error.toString())));
          sink.close();
        },
      ),
    );
```
