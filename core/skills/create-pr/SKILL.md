---
name: create-pr
description: Tạo Pull Request vào main. Luôn cập nhật main (pull --rebase), rồi quay lại nhánh đang làm và rebase lên main trước khi push và mở PR. Dùng khi tôi nói "tạo PR", "mở PR", "đẩy lên review", hoặc gọi /create-pr.
argument-hint: "[--draft | <ghi chú cho mô tả PR>]"
---

# Create PR

Quy ước nhánh/commit ở `.claude/rules/git.md`. Nhánh đích **luôn là `main`** (nếu repo dùng tên khác thì lấy từ `git symbolic-ref --short refs/remotes/origin/HEAD`, bỏ `origin/`). `--draft` = mở PR ở dạng draft.

Thứ tự bắt buộc — **không được bỏ bước 2–4 dù nhánh trông đã mới**: về main → pull --rebase → về nhánh làm việc → rebase lên main → mới push/tạo PR.

## 1. Chuẩn bị

1. `git branch --show-current` → ghi nhớ làm `<branch>`. Đang ở `main`/`master` → dừng, không tạo PR từ nhánh chính.
2. Tên nhánh phải đúng `{feature|refactor|fix|chore}/{tên-dự-án}/{tên-việc}`; sai thì báo tôi (không tự đổi tên).
3. `git status --short`: còn thay đổi chưa commit → dừng, đề nghị chạy `/commit` trước. Không stash, không bỏ qua.
4. `git log main..HEAD --oneline` (sau bước 2 mới chính xác) phải có ít nhất 1 commit, nếu không báo "không có gì để tạo PR".
5. `git fetch origin --prune`.

## 2. Cập nhật main

```bash
git checkout main
git pull --rebase origin main
```
- `main` local có commit riêng chưa push (khác `origin/main`) → dừng và báo tôi, không tự xử lý.
- Pull lỗi/conflict → dừng, báo nguyên nhân. Không `--force`, không `reset --hard`.

## 3. Quay lại nhánh làm việc

```bash
git checkout <branch>
```

## 4. Rebase nhánh hiện tại lên main (rebase current changes onto main)

Đang đứng ở `<branch>`, đặt các commit của nhánh này lên trên đầu `main` mới nhất:
```bash
git rebase main
```
Hướng rebase là **nhánh làm việc → lên main**; không rebase `main` lên nhánh, không merge `main` vào nhánh, không `git pull` vào nhánh làm việc.
- Có conflict: liệt kê file conflict (`git status`), đọc hai phía và giải quyết **chỉ khi ý định rõ ràng và cả hai phía đều giữ được**; mỗi file xong `git add <file>` rồi `git rebase --continue`. Không rõ ý định → `git rebase --abort`, báo tôi từng file và hai phương án, chờ tôi quyết.
- Không dùng `-X ours/theirs` hay `--skip` để cho qua.
- Rebase xong, chạy kiểm tra nhanh nếu project có (`/check` hoặc tối thiểu `flutter analyze` + `flutter test`). Fail do thay đổi từ main → báo tôi trước khi push.

## 5. Push

1. Kiểm tra nhánh đã có trên remote chưa: `git ls-remote --heads origin <branch>`.
   - Chưa có → `git push -u origin <branch>`.
   - Có và rebase **không đổi** lịch sử đã push (`git status` báo up to date / chỉ ahead) → `git push`.
   - Có nhưng rebase đã viết lại commit (báo diverged) → cần `git push --force-with-lease origin <branch>`. **Hỏi tôi xác nhận trước** (nêu tên nhánh và số commit sẽ bị ghi đè), chỉ chạy trên nhánh này, không bao giờ trên `main`, không dùng `--force` trần.
2. Push bị từ chối vì lý do khác → báo tôi, không tự xử lý.

## 6. Tạo PR

Dùng `gh pr create --base main --head <branch>`; trước đó `gh pr view <branch>` — đã có PR mở thì không tạo mới, chỉ cho tôi link PR đó (đã push thêm commit thì PR tự cập nhật).

- **Title**: theo format commit — `{type}({tên-dự-án}): {mô tả tiếng Anh}`. Một commit thì lấy chính message đó; nhiều commit thì viết một dòng tổng hợp theo loại nhánh.
- **Body** (tiếng Anh, ngắn gọn; thêm ghi chú của tôi nếu có):
  ```
  ## Summary
  - <các thay đổi chính, 2–5 gạch đầu dòng>

  ## Changes
  - <nhóm theo tầng/feature nếu diff lớn>

  ## Test plan
  - [ ] flutter analyze
  - [ ] flutter test
  - [ ] <các màn hình/luồng cần test tay>
  ```
  Dựa vào `git log main..HEAD` và `git diff main...HEAD --stat`, không bịa thay đổi. Mục nào đã chạy thật trong phiên này thì tick, chưa chạy thì để trống.
- Không thêm dòng attribution (Co-Authored-By, "Generated with...") vào body, giống quy tắc commit. 
- Heredoc cho body:
  ```bash
  gh pr create --base main --head <branch> --title "<title>" --body "$(cat <<'EOF'
  ...
  EOF
  )"
  ```

## 7. Báo cáo

Liệt kê: kết quả pull main (có commit mới không), rebase (số commit, có conflict không, đã giải quyết thế nào), push (thường hay force-with-lease), link PR, và việc cần tôi làm tiếp (reviewer, test tay). Không tự merge PR, không tự gán reviewer.
