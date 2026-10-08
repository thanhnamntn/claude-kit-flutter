---
name: refactor-to-pattern
description: Refactor một feature/Page/Notifier/State về pattern và cấu trúc chuẩn hiện tại của project — feature gồm pages/notifiers/state/widgets, Page display-only (ConsumerWidget), sealed state, notifier có _fetch() và đi qua UseCase, không import data layer. Dùng khi page có local state cho logic (fetch flag, pagination, loading), state không phải sealed class, page/notifier import thẳng data/ (Model, DataSource), file nằm sai thư mục, page quá dài cần tách widgets, hoặc tôi nói "refactor theo pattern chuẩn".
argument-hint: "<đường dẫn page hoặc tên feature>"
---

# Refactor to pattern

Đối tượng: `$ARGUMENTS` (nếu thiếu, hỏi lại). Mẫu chuẩn: tìm một page đã đúng chuẩn trong repo (`ConsumerWidget`, zero local state, `switch` exhaustive) cùng notifier và state của nó, dùng làm mẫu so sánh.

Đọc trước khi bắt đầu: `.claude/rules/presentation.md`, `.claude/rules/imports.md`, `.claude/rules/structure.md`, và `STRUCTURE.md` (cấu trúc feature chuẩn).

## Cấu trúc chuẩn của một feature

```
lib/features/<feature>/
├── pages/       # Page (UI, display-only)
├── notifiers/   # NotifierProvider: logic + state transitions
├── state/       # sealed class state
└── widgets/     # Widget riêng của feature (bỏ folder nào không có file)
```
Mỗi folder có từ 3 file `.dart` trở lên có `index.dart`. Feature chỉ lấy dữ liệu qua UseCase/provider và dùng **Entity**; không import `data/` (Model, DataSource, GraphQL).

## 1. Audit (chưa sửa gì)

Đọc page, notifier, state, widgets của đối tượng, rồi liệt kê vi phạm:

**Cấu trúc**
- [ ] File nằm sai thư mục (page ngoài `pages/`, notifier/provider ngoài `notifiers/`, state ngoài `state/`), hoặc có thư mục ngoài `pages/ notifiers/ state/ widgets/`.
- [ ] Folder ≥ 3 file chưa có `index.dart`, hoặc barrel thiếu export, hoặc còn import tương đối (`../`).
- [ ] Page dài, chứa nhiều widget con private lớn → tách sang `widgets/`.

**Page**
- [ ] Là `ConsumerStatefulWidget` nhưng không cần vsync/`TextEditingController`/`ScrollController`.
- [ ] Có biến local cho logic: `_fetchTriggered`, `_currentPage`, `_isLoading`, pagination flag, `initState` gọi fetch.
- [ ] Chứa logic nghiệp vụ/format/tính toán/gọi UseCase trực tiếp thay vì để ở notifier hoặc domain.
- [ ] Biến `ref.watch` đặt tên chung `state`.
- [ ] Dùng `if`/`is` thay vì `switch` exhaustive trên state.

**State & Notifier**
- [ ] State không phải `sealed class`, hoặc substate dùng `final class`/`const` constructor.
- [ ] Notifier có `build()` lấy data nhưng không tách `_fetch()`.
- [ ] Provider không dùng `NotifierProvider.autoDispose`.
- [ ] Notifier gọi DataSource/Repository trực tiếp thay vì UseCase.

**Phụ thuộc tầng**
- [ ] File trong feature import `package:<tên_package>/data/...` (Model, DataSource, GraphQL, Mapper) → đi qua UseCase/provider, dùng Entity; thiếu Entity/UseCase/provider thì đề xuất tạo theo `/new-feature`.
- [ ] Dùng chuỗi BE hoặc `toGraphQL()`/`fromGraphQL()` trong feature → dùng enum domain.
- [ ] Feature import trực tiếp feature khác (trừ `shell`) → chuyển phần dùng chung sang `share/` hoặc domain.

**Giao diện**
- [ ] Constant màu ở cấp file hoặc `Color(0x...)` trực tiếp → theme/colors của project.
- [ ] Chuỗi hiển thị hard-code, chưa dùng `.tr()` (key có ở mọi file ngôn ngữ).

Trình bày danh sách + kế hoạch sửa ngắn gọn, rồi mới làm. Nếu thay đổi ảnh hưởng nhiều feature hoặc đụng domain/data (thêm Entity, UseCase, Mapper), nói rõ phạm vi trước khi làm.

## 2. Refactor

Làm theo thứ tự state → notifier → page → widgets để mỗi bước compile được.

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
Mọi thứ page đang giữ local (page index, hasMore, isLoadingMore, selection...) chuyển thành field của state `Data` (hoặc substate riêng).

**Notifier** (`features/<feature>/notifiers/<feature>_page_notifier.dart`)
- `build()` chỉ trả `XxxPageLoading()` rồi gọi `_fetch()` (hoặc `return _fetch()` nếu đồng bộ).
- Logic lấy data trong `_fetch()`; refresh dùng lại `_fetch()`.
- Gọi UseCase qua provider (`core/providers`), xử lý bằng `fold`; lỗi → `XxxPageError(failure.message)`.
- Method public cho page gọi (`fetchAll`, `loadMore`, `retry`...) — page không tự giữ logic.
- Provider: `NotifierProvider.autoDispose<XxxPageNotifier, XxxPageState>(XxxPageNotifier.new)`.

**Page** (`features/<feature>/pages/<feature>_page.dart`)
- `ConsumerWidget`; `final <feature>State = ref.watch(<feature>PageProvider);`
- `switch (<feature>State)` exhaustive trên mọi substate; không `default`.
- Hành vi (retry, refresh, load more) gọi `ref.read(provider.notifier).method()`.
- Nếu còn cần controller thật (scroll/text/animation) mới giữ `ConsumerStatefulWidget`, và chỉ chứa controller, không chứa logic.

**Widgets** (`features/<feature>/widgets/`)
- Widget con lớn trong page tách thành file riêng (`xxx_section.dart`...), nhận dữ liệu qua constructor hoặc `ConsumerWidget` đọc provider; không nhân đôi logic.
- Tạo/cập nhật `index.dart` khi folder đạt 3 file.

**Phụ thuộc data** — nếu feature đang dùng Model/DataSource:
- Thêm Entity (`domain/entities/`), Mapper (`data/mappers/`), UseCase/Params, provider (`core/providers/`) theo `/new-feature`; RepositoryImpl convert Model → Entity.
- Feature chỉ còn thấy Entity và UseCase.

**Di chuyển file** — dùng `git mv` để giữ lịch sử; sửa import `package:<tên_package>/...` và file routes; cập nhật `index.dart` của folder cũ và mới.

## 3. Kiểm tra

1. `bash .claude/scripts/check_structure.sh` — barrel, import tương đối, hướng phụ thuộc, khớp `STRUCTURE.md`.
2. `dart format .`
3. `flutter analyze` — không còn lỗi `switch` thiếu case hoặc import hỏng.
4. `flutter test` — nếu có test notifier/state thì cập nhật; nếu notifier mới có logic (pagination, load more) thì đề xuất thêm test theo `.claude/rules/tests.md`.

## 4. Báo cáo

Liệt kê: vi phạm đã sửa, file đổi/di chuyển, hành vi có thể thay đổi (ví dụ thời điểm fetch, trạng thái loading), và việc còn lại tôi cần quyết định. Không tự thêm tính năng ngoài phạm vi refactor.

## Lưu ý

- Chỉ sửa đối tượng được giao; thấy feature khác lệch rule thì báo lại, không sửa lan.
- Nếu refactor thêm/xóa/đổi tên folder → cập nhật `STRUCTURE.md` cùng lúc (xem `.claude/rules/structure.md`).
- Giữ nguyên UI/hành vi nhìn thấy được; đây là refactor cấu trúc, không phải redesign.
