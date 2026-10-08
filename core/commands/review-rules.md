---
description: Review diff hiện tại theo các rule của project (.claude/rules + CLAUDE.md)
argument-hint: "[branch | file | để trống = diff so với nhánh chính]"
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Read, Grep
---

Review thay đổi `$ARGUMENTS` (mặc định: `git diff` + file untracked của nhánh hiện tại so với nhánh chính). Chỉ đọc, không sửa file.

1. Đọc `CLAUDE.md` và các file trong `.claude/rules/` khớp với file đổi.
2. Với mỗi rule, kiểm tra diff có vi phạm không — chỉ những gì linter KHÔNG bắt được (kiến trúc, phân tầng, quy ước đặt tên/vị trí, xử lý lỗi, chuỗi hiển thị/i18n, test còn thiếu).
3. Nếu thay đổi cần release, kiểm tra quy tắc version của project (nếu có).

Output: danh sách vi phạm theo mức độ (cao → thấp), mỗi mục `file:line` + rule vi phạm + gợi ý sửa ngắn. Nếu không có vi phạm, nói rõ là sạch.
