---
description: Format, analyze và test project, báo lỗi gọn
allowed-tools: Bash(bash .claude/scripts/check_structure.sh:*), Bash(dart format:*), Bash(flutter analyze:*), Bash(flutter test:*)
---

Chạy lần lượt từ thư mục gốc project, dừng ở bước đầu tiên fail nghiêm trọng:

1. `bash .claude/scripts/check_structure.sh` (cấu trúc: barrel, import, hướng phụ thuộc, khớp STRUCTURE.md)
2. `dart format .`
3. `flutter analyze`
4. `flutter test`

Báo cáo:
- Mỗi bước: pass/fail.
- Với lỗi/warning analyze: liệt kê `file:line` + rule (rule trong `analysis_options.yaml`).
- Với test fail: tên test + message ngắn gọn.
- Không tự sửa code trừ khi tôi yêu cầu; chỉ đề xuất cách sửa.
