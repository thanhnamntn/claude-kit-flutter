---
description: Scaffold feature mới theo Clean Architecture (domain → data → presentation)
argument-hint: "<feature_name> [entity_name]"
---

Tạo feature mới `$ARGUMENTS` (snake_case cho file, PascalCase cho class). Nếu thiếu tên, hỏi lại.

Trước khi tạo, đọc `CLAUDE.md`, `.claude/rules/` và `STRUCTURE.md` (nếu có), rồi mở một feature hoàn chỉnh gần nhất trong repo làm mẫu để bắt chước đúng layout thư mục và naming. Đường dẫn dưới đây là layout mặc định — nếu project khác thì theo project. Không bịa API/route/endpoint; nếu cần query hoặc endpoint mới, hỏi tôi.

## Domain (`lib/domain/`)
- `entities/<name>_entity.dart` — class có hậu tố `Entity`, không import Model.
- `datasources/<name>_datasource.dart` — abstract interface, trả về `XxxModel`.
- `repositories/<name>_repository.dart` — abstract, trả về `Either<Failure, XxxEntity>`.
- `usecases/<verb>_<name>_usecase.dart` — `XxxParams extends Equatable` + `UseCase`, verb theo mục Naming trong `.claude/rules/data-layer.md`.
- `models/<name>_model.dart` — chỉ `fromJson`/`toJson`; export qua `index.dart` nếu thư mục có barrel.

## Data (`lib/data/`)
- `mappers/<name>_mapper.dart` — constructor private `._()`, static `toEntity(model)`.
- `datasources/<name>_datasource_impl.dart` — impl gọi API (GraphQL/REST).
- `repositories/<name>_repository_impl.dart` — field `remoteDataSource`, try/catch → `Right(mapped)` / `Left(ServerFailure(e.toString()))`.

## Providers (`lib/core/providers/`)
Mỗi file một provider, rồi thêm `export` vào `lib/core/providers/index.dart`:
- `datasource/<name>_data_source_provider.dart`
- `repository/<name>_repository_provider.dart`
- `usecase/<verb>_<name>_usecase_provider.dart`

## Presentation (`lib/features/<feature>/`)
- `state/<feature>_page_state.dart` — `sealed class` + substate `class` thường (Loading / Data / Error).
- `notifiers/<feature>_page_notifier.dart` — `Notifier` + `NotifierProvider.autoDispose`; `build()` chỉ `return _fetch()` (hoặc set Loading rồi gọi `_fetch`), logic trong `_fetch()`; xử lý kết quả bằng `fold`.
- `pages/<feature>_page.dart` — `ConsumerWidget` display-only, `switch` exhaustive trên state, tên biến watch cụ thể (vd `<feature>State`), không có local state logic.
- `widgets/` — widget riêng của feature (tạo thư mục khi cần).

## Quy tắc chung
- Import `package:<tên_package>/...`, single quotes, trailing commas, params `required` đứng trước.
- Không throw raw exception; dùng `Either<Failure, T>`.
- Không thêm route/mock datasource trừ khi tôi yêu cầu (nếu thêm route thì sửa file routes của project).

Cuối cùng chạy `dart format .` và `flutter analyze`, rồi liệt kê các file đã tạo và việc còn lại (route, query/endpoint, key localization).

Nếu feature/folder mới làm đổi cây thư mục: cập nhật `STRUCTURE.md` và chạy `bash .claude/scripts/check_structure.sh` (xem `.claude/rules/structure.md`).
