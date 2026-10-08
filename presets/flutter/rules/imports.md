# Import & barrel rules

Rule không có `paths:` nên luôn được nạp.

- Mọi folder có từ 3 file `.dart` trở lên phải có `index.dart` (barrel) export toàn bộ file trong folder: `library;` rồi các dòng `export 'xxx.dart';` theo thứ tự alphabet.
- Folder đã có barrel: import qua `index.dart` thay vì từng file lẻ, để giảm số dòng import:
  `import 'package:<app>/domain/entities/index.dart';`
- Khi thêm hoặc xóa file trong folder có barrel, cập nhật `index.dart` cùng lúc.
- File nằm trong chính folder của barrel thì import file anh em trực tiếp, không import qua `index.dart` của folder mình.
- Luôn dùng import `package:`; thứ tự import theo `directives_ordering` (chạy `dart fix --apply --code=directives_ordering` nếu cần).
- Danh sách folder có barrel: liệt kê theo project.
- Hướng phụ thuộc (không import ngược): `features → domain`; `data → domain`; `core/providers` nối `data` + `domain`; `share → domain/core` (không import `features/`); `domain` không import `data/`, `share/`, `features/`; `features` không import `data/` (lấy dữ liệu qua UseCase/provider); `data` không import `share/`, `features/`.
