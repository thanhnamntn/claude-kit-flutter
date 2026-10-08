---
paths:
  - "lib/**"
  - "STRUCTURE.md"
---

# Structure rules

`STRUCTURE.md` là nguồn sự thật về cây thư mục `lib/`. Mọi thay đổi cây thư mục phải cập nhật `STRUCTURE.md` **trong cùng commit**.

- Cần cập nhật khi: thêm, xóa, đổi tên hoặc di chuyển **folder** trong `lib/`; thêm/xóa/đổi tên file ở mức cấu trúc (file trong `environment/`, `lib/` gốc, lớp cơ sở); đổi vai trò một folder.
- Không cần khi chỉ thêm/sửa/xóa file thường trong folder đã có (page, notifier, entity, mapper...).
- Feature mới: dùng đúng 4 folder `pages/ notifiers/ state/ widgets/` (bỏ folder nào không có file); `STRUCTURE.md` chỉ mô tả feature mẫu `<feature>`, không liệt kê từng feature.
- Folder mới có từ 3 file `.dart` trở lên: thêm `index.dart` (xem `imports.md`).
- Cập nhật xong chạy `bash .claude/scripts/check_structure.sh` (hoặc `/check`); script báo lệch giữa `STRUCTURE.md` và thư mục thực tế, barrel thiếu, import tương đối, hướng phụ thuộc.
- Khi đổi cấu trúc ảnh hưởng nhiều project (đổi quy ước chung), cập nhật cả bản mẫu trong `claude-kit/presets/flutter/STRUCTURE.md`.
