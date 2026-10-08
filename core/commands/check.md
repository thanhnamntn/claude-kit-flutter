---
description: Format, lint và test project, báo lỗi gọn
---

Đọc mục Commands trong `CLAUDE.md` để lấy lệnh format, lint và test của project (nếu thiếu, hỏi tôi rồi đề xuất bổ sung vào `CLAUDE.md`).

Chạy lần lượt: format → lint/analyze → test. Dừng ở bước đầu tiên fail nghiêm trọng.

Báo cáo:
- Mỗi bước: pass/fail.
- Lỗi lint: `file:line` + rule.
- Test fail: tên test + message ngắn.
- Không tự sửa code trừ khi tôi yêu cầu; chỉ đề xuất cách sửa.
