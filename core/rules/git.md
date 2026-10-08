# Git branch & commit rules

Rule không có `paths:` nên luôn được nạp.

## Tên nhánh

```
{loại}/{tên-dự-án}/{tên-việc}
```

| Loại | Dùng khi | Ví dụ |
|---|---|---|
| `feature` | Thêm tính năng/màn hình mới | `feature/my-app/build-ui-member` |
| `refactor` | Đổi cấu trúc code, không đổi hành vi | `refactor/my-app/move-data-domain-out-of-core` |
| `fix` | Sửa lỗi | `fix/my-app/payment-webview-polling` |
| `chore` | Việc vặt không đổi code chạy: cập nhật dependency, config, build/version, tài liệu, rule `.claude` | `chore/my-app/update-build-version` |

- `{tên-dự-án}`: tên dự án, chữ thường, nối bằng `-` (lấy theo tên repo/package).
- `{tên-việc}`: mô tả việc đang làm, chữ thường, các từ nối bằng `-`, không dấu, không khoảng trắng hay `_`.
- Chọn loại theo bản chất công việc; mỗi nhánh chỉ một loại. Việc vừa fix vừa refactor (hoặc lẫn chore) thì tách thành các nhánh/commit riêng.
- Khi tạo nhánh mới luôn đặt tên theo format trên.
- Nhánh mới **luôn tạo từ `main`**, và trước đó phải cập nhật `main`: `git checkout main` → `git pull --rebase origin main` → rồi mới `git checkout -b <nhánh>`. Không tạo nhánh từ một nhánh làm việc khác (trừ khi tôi chỉ định rõ). Có thay đổi dở thì dừng và báo tôi, không stash tự ý.

## Commit message

```
{loại}({tên-dự-án}): {công việc liên quan tới commit}
```

| Loại | Dùng khi | Ví dụ |
|---|---|---|
| `feat` | Tính năng mới | `feat(my-app): add member profile page` |
| `refactor` | Đổi cấu trúc, không đổi hành vi | `refactor(my-app): move beverage logic to notifiers` |
| `fix` | Sửa lỗi | `fix(my-app): stop polling after payment completed` |
| `chore` | Dependency, config, build/version, tài liệu, rule `.claude` | `chore(my-app): bump version to 1.0.2+3` |

- Loại commit đi theo loại nhánh: nhánh `feature` → `feat`, nhánh `refactor` → `refactor`, nhánh `fix` → `fix`, nhánh `chore` → `chore`.
- `{tên-dự-án}` giống phần tên dự án trong tên nhánh.
- Phần mô tả: tiếng Anh, ngắn gọn, động từ nguyên mẫu ở đầu (add, update, move, fix...), nêu việc cụ thể của commit đó.
- Không thêm dòng `Co-Authored-By` (hay bất kỳ attribution nào) vào commit message.
