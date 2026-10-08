---
description: Review diff hiện tại theo các rule [manual] của project
argument-hint: "[branch | file | để trống = git diff hiện tại]"
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Read, Grep
---

Review thay đổi `$ARGUMENTS` (mặc định: `git diff` + file untracked của branch hiện tại so với `main`). Chỉ đọc, không sửa file.

Đọc `CLAUDE.md` và `.claude/rules/`, rồi kiểm tra các rule mà `flutter analyze` KHÔNG bắt được:

**Kiến trúc**
- Entity không import Model; mapping chỉ ở `RepositoryImpl` qua `XxxMapper.toEntity`; Mapper có `._()` + static.
- Entity class có hậu tố `Entity`, nằm trong `domain/entities/`.
- Provider chain `dataSource → repository → useCase → notifier`; notifier không gọi DataSource trực tiếp.
- Hướng phụ thuộc: `domain` không import `data/`, `share/`, `features/`; `features` không import `data/`; `share` không import `features/`; `data` không import `share/`/`features/`. Chạy `bash .claude/scripts/check_structure.sh`.
- Domain layer không import Flutter.
- Chuỗi BE (`toGraphQL`/`fromGraphQL`) chỉ dùng trong `data/`.
- Đổi cây thư mục → `STRUCTURE.md` đã được cập nhật.

**Quy ước code**
- Repository: field `remoteDataSource`, try/catch → `Either`, stream dùng `StreamTransformer.fromHandlers`; không `throw` raw.
- Thứ tự method: list → batchGet → get → create → update → delete → domain-specific.

**Presentation**
- State là `sealed class`, substate dùng `class` thường; UI dùng `switch` exhaustive.
- Notifier có `_fetch()` riêng; `build()` chỉ gọi nó.
- Page display-only: không local state cho logic (flag, pagination); chỉ `ConsumerStatefulWidget` khi cần controller/vsync.
- Biến `ref.watch` không đặt tên chung `state`.

**Khác**
- Chuỗi hiển thị dùng localization của project, key đủ ở mọi ngôn ngữ hỗ trợ.
- Thay đổi cần release → `version:` trong `pubspec.yaml` (số BUILD tăng?).
- Test thiếu cho usecase/mapper/repository/notifier mới (`.claude/rules/tests.md`).

Output: danh sách vi phạm theo mức độ (cao → thấp), mỗi mục `file:line` + rule vi phạm + gợi ý sửa ngắn. Nếu không có vi phạm, nói rõ là sạch.
