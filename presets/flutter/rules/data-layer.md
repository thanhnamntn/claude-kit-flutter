---
paths:
  - "lib/data/**"
  - "lib/core/providers/**"
---

# Data layer & providers rules

- Mapper: constructor private `._()`, chỉ static method `toEntity(model)`. Mapping Model → Entity xảy ra trong `RepositoryImpl`.
- RepositoryImpl: field inject tên `remoteDataSource`; `try/catch` → `Right(...)` / `Left(ServerFailure(e.toString()))`; void dùng `Right(null)`.
- Stream không dùng try/catch: `.map(Right)` + `.transform(StreamTransformer.fromHandlers(...))` (cần `import 'dart:async'`).
- DataSource interface nằm ở `data/datasources/` cùng impl (trả Model); domain không biết Model. Chuỗi BE của enum (`toGraphQL`/`fromGraphQL`) đặt ở `data/mappers/enum_graphql_mapper.dart`.
- DataSource impl chỉ gọi API (GraphQL/HTTP), không chứa business logic. Local/mock datasource không bị xóa.
- Provider chain: `dataSource → repository → useCase → notifier`. Mỗi provider một file, đặt theo layout của project (xem `STRUCTURE.md`/`CLAUDE.md`); nếu có barrel `index.dart` thì phải export provider mới.
- Thứ tự method trong class: list → batchGet → get → create → update → delete → domain-specific.
- Named params: `required` đứng trước optional.

## Naming

| Verb | Khi nào | Ví dụ |
|---|---|---|
| `list` | Lấy nhiều item | `listBeverages()` |
| `get` | Lấy 1 item theo ID | `getTransaction(id)` |
| `batchGet` | Lấy nhiều item theo danh sách ID | `batchGetCombos(ids)` |
| `create` / `update` / `delete` | CRUD | `createTransaction()` |
| `cancel` / `complete` | Đổi trạng thái domain | `cancelTransaction()` |

- File: `snake_case.dart`; interface `xxx.dart` + implementation `xxx_impl.dart`.
- DataSource impl đặt tên theo nguồn dữ liệu: `xxx_datasource_impl.dart` (nguồn thật), `xxx_mock_datasource_impl.dart` (mock), `xxx_hardcoded_datasource_impl.dart` (dữ liệu hardcode trong app); không dùng tên chung `_local_`.
- Barrel file luôn tên `index.dart`.

## Stream trong Repository

Stream không dùng được try/catch — bọc lỗi bằng `StreamTransformer.fromHandlers`:

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
