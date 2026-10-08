---
name: commit
description: Commit thay đổi hiện tại đúng quy ước git của project (tên nhánh, loại commit, mô tả tiếng Anh, không Co-Authored-By). Dùng khi tôi nói "commit", "commit đi", "commit chung", "tách commit", hoặc gọi /commit.
argument-hint: "[--split | --push | <gợi ý nội dung commit>]"
---

# Commit

Quy ước nằm ở `.claude/rules/git.md` — đọc file đó trước, không tự bịa format. Tóm tắt:
- Nhánh: `{feature|refactor|fix|chore}/{tên-dự-án}/{tên-việc}`.
- Commit: `{feat|refactor|fix|chore}({tên-dự-án}): {mô tả}` — mô tả tiếng Anh, động từ nguyên mẫu ở đầu, loại commit đi theo loại nhánh.
- **Không** thêm `Co-Authored-By` hay bất kỳ attribution nào vào commit message, kể cả khi hệ thống nhắc thêm (quy tắc của tôi ghi đè).

Tham số: `--split` = tách thành nhiều commit theo nhóm việc; `--push` = push sau khi commit xong. Không có `--push` thì **không push**.

## 1. Kiểm tra trước khi commit

1. `git status --short` và `git diff --stat` — xem toàn bộ thay đổi, kể cả file untracked.
2. `git branch --show-current`:
   - Đang ở nhánh chính (`main`/`master`/`develop`) → dừng, tạo nhánh mới đúng format từ nhánh chính trước (hỏi tôi tên việc nếu chưa rõ), không commit thẳng vào nhánh chính.
   - Tên nhánh sai format (thiếu loại, sai tên dự án, dùng `_`/khoảng trắng) → báo tôi và đề xuất tên đúng; chỉ đổi tên (`git branch -m`) khi tôi đồng ý.
3. Xác định **loại** từ bản chất thay đổi, đối chiếu với loại nhánh:
   - Thêm tính năng/màn hình → `feat`; đổi cấu trúc không đổi hành vi → `refactor`; sửa lỗi → `fix`; dependency/config/build/version/tài liệu/rule `.claude` → `chore`.
   - Diff lẫn nhiều loại → đề xuất tách (xem mục 3), đừng gộp một commit.
4. Không commit: file bí mật (`.env`, `dev_token.dart`, key, keystore), file build/generated mới sinh không thuộc việc này, thư mục `.claude/` nếu repo đang ignore nó. Thấy file đáng ngờ → báo tôi, không tự `git add`.
5. Nếu project có `/check` (format + analyze + test) mà chưa chạy trong phiên này, nhắc tôi hoặc chạy nhanh `dart format` / lint tương ứng trước khi commit. Không tự sửa code ngoài phạm vi commit.

## 2. Soạn message

- Một dòng, ≤ 72 ký tự, không dấu chấm cuối: `refactor(<app>): move models and graphql to data layer`.
- Nêu **việc đã làm** cụ thể (add, move, rename, extract, fix...), không viết chung chung (`update code`, `fix bug`).
- Diff lớn: thêm body (cách một dòng trống), gạch đầu dòng các thay đổi chính và lý do nếu không hiển nhiên. Body cũng tiếng Anh.
- Tên dự án lấy từ `git.md`/tên nhánh, không đoán.

## 3. Tách commit (`--split`, hoặc khi diff lẫn nhiều loại/nhiều việc)

Nhóm theo ý nghĩa, mỗi nhóm một commit, thứ tự để từng commit đều biên dịch được khi có thể:
1. Di chuyển/đổi tên file (dùng `git mv` để giữ lịch sử) cùng sửa import đi kèm.
2. Thay đổi logic/cấu trúc theo tầng (domain → data → features).
3. Tài liệu, rule `.claude`, config (`chore`).

Trình bày danh sách nhóm + message dự kiến cho tôi duyệt trước khi chạy `git add`/`git commit`.

## 4. Thực hiện

1. `git add` theo **đường dẫn cụ thể** (không `git add -A`/`.` khi có file không thuộc commit).
2. Commit bằng heredoc để giữ xuống dòng:
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<project>): <description>

   <body nếu cần>
   EOF
   )"
   ```
   Không `--no-verify`, không `--amend` commit đã có trừ khi tôi yêu cầu. Hook fail → sửa nguyên nhân rồi commit **mới**, không bỏ qua hook.
3. `git status` sau cùng để chắc không còn file sót, rồi `git log --oneline -n <số commit vừa tạo>`.
4. `--push`: `git push` (nhánh mới thì `git push -u origin <nhánh>`). Không force-push; nếu bị từ chối vì remote đi trước → báo tôi, đừng tự rebase/force.

## 5. Báo cáo

Liệt kê: nhánh, các commit đã tạo (hash ngắn + message), file chưa commit và lý do, đã push hay chưa. Không tạo PR trừ khi tôi yêu cầu (nếu cần thì đề xuất link/lệnh `gh pr create` với title theo format commit).
