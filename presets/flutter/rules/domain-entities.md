---
paths:
  - "lib/domain/**"
---

# Domain layer rules

- Domain là pure Dart: không import Flutter và **không import `lib/data/**`** (Model, GraphQL, DataSource nằm ở data layer).
- Entity: hậu tố `Entity`, đặt trong `domain/entities/`, không import Model.
- Model (`data/models/`) chỉ mirror BE response với `fromJson`/`toJson`; chỉ data layer (DataSource, RepositoryImpl, Mapper) được dùng Model. Mapper convert Model → Entity.
- DataSource interface (`data/datasources/`) trả về Model; Repository interface (domain) và UseCase chỉ nhận/trả Entity hoặc Params do domain định nghĩa, dạng `Either<Failure, Entity>`.
- Params (`XxxParams extends Equatable`) đặt trong `domain/params/`, không để trong file usecase — repository interface cũng dùng chúng, để `repositories` và `usecases` không import lẫn nhau.
- UseCase: một trách nhiệm, trả `Either<Failure, T>`. Tên theo verb chuẩn (xem mục Naming trong `data-layer.md`).
- Enum (`domain/enums/`) chỉ khai báo giá trị và helper không phụ thuộc BE. Chuyển đổi sang/từ chuỗi BE (`toGraphQL`/`fromGraphQL`) nằm ở `data/mappers/enum_graphql_mapper.dart`; domain và features dùng enum, không truyền chuỗi BE. Enum thuần UI (vd tab điều hướng) đặt trong feature dùng nó.
- Không throw exception raw; dùng `Either<Failure, T>`.
- Không dùng prefix `k` cho constant.
- Validator dùng chung nhiều màn hình, độc lập entity (phone, email, ngày, thẻ) đặt ở `core/validators/` (hàm thuần Dart, trả `bool`, không `.tr()`; cần thời gian thì nhận `now`). Luật gắn chặt một entity thì viết trong entity/rules class ở `domain/entities/`. Thông báo lỗi dịch ở notifier/UI, không dịch trong validator.
