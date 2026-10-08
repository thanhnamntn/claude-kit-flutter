---
paths:
  - "lib/features/**/pages/**"
  - "lib/features/**/notifiers/**"
  - "lib/features/**/state/**"
  - "lib/features/**/widgets/**"
---

# Presentation rules

- Page là display-only: ưu tiên `ConsumerWidget`. Chỉ dùng `ConsumerStatefulWidget` khi cần `AnimationController` (vsync), `TextEditingController` hoặc `ScrollController`.
- Không khai báo local state cho logic trong Page (fetch flag, pagination index, loading flag) — để ở notifier/state.
- Tên biến `ref.watch` phải cụ thể theo feature (`homeState`, `ordersState`), không đặt `state` chung chung.
- State dùng `sealed class`; substate là `class` thường (không `final class`, không cần `const` constructor). UI dùng `switch` exhaustive để compiler báo khi thiếu case.
- Notifier có `build()` lấy data thì tách logic ra `_fetch()`; `build()` chỉ gọi `_fetch()`. Refresh dùng `state = _fetch()`.
- Feature không import `data/` (Model, DataSource, GraphQL): dữ liệu đi qua UseCase/provider và là Entity.
- Notifier không gọi DataSource trực tiếp — đi qua UseCase; xử lý kết quả bằng `fold`.
- Provider của notifier dùng `NotifierProvider.autoDispose`.
- Chuỗi hiển thị đi qua localization của project, thêm key ở mọi ngôn ngữ hỗ trợ.
- Page chỉ chứa UI: không khai báo constant màu/style ở cấp file hay `Color(0x...)` rải trong page/widget. Dùng `AppColors` (`share/theme/app_colors.dart`) và `AppTheme`; màu mới thì thêm vào đó.
- Widget chỉ một feature dùng đặt ở `features/<feature>/widgets/`; chỉ khi từ 2 feature trở lên dùng mới đưa vào `share/widgets/`. `share/` không chứa model, provider hay logic nghiệp vụ.
- Feature không import feature khác (ngoại lệ: khung app dùng chung như `shell`, hoặc một helper chung được ghi rõ trong rule của project).
- Không gọi `.tr()` ở nơi chỉ chạy một lần (route builder, hằng số cấp file, state/notifier lưu sẵn chuỗi) vì đổi ngôn ngữ sẽ không cập nhật. Truyền key và dịch trong `build()`; đổi ngôn ngữ qua một helper dựng lại cả cây widget thay vì chỉ gọi `context.setLocale`.
