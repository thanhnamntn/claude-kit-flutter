---
name: check-translations
description: Kiểm tra toàn bộ translation (easy_localization) của project — key thiếu giữa en/vi, key dùng trong code nhưng chưa định nghĩa, key thừa, placeholder lệch, text hard-code chưa dịch. Dùng khi thêm/sửa chuỗi hiển thị, trước khi tạo PR, hoặc khi tôi nói "check translate/i18n/dịch".
argument-hint: "[--fix | để trống = chỉ báo cáo]"
---

# Check translations

Translation nằm ở `assets/translations/{en,vi}.json`; code dùng `'a.b.c'.tr()` (`easy_localization`). Quy ước: mọi chuỗi hiển thị đều qua `.tr()` và có key ở **mọi** ngôn ngữ hỗ trợ.

## 1. Chạy kiểm tra

```bash
python3 .claude/skills/check-translations/scripts/check_translations.py --hardcoded
```

Script (không sửa file) báo 5 nhóm:

1. Key thiếu giữa các ngôn ngữ (có ở `en` mà không có ở `vi`, hoặc ngược lại).
2. Key dùng trong code (`'x.y'.tr(`, `tr('x.y'`, string literal truyền như `'questionKey': 'x.y'`) nhưng chưa định nghĩa.
3. Key định nghĩa nhưng không thấy dùng. Key ghép động (`'prefix.$var'`) được bỏ qua theo prefix; **luôn kiểm tra tay trước khi xóa** vì key có thể được dựng bằng cách khác.
4. Giá trị rỗng, hoặc placeholder (`{}`, `{name}`) lệch giữa các ngôn ngữ.
5. (`--hardcoded`) Text hard-code trong `Text('...')`, `label:`, `hint:`, `title:`... chưa dịch — chỉ là ứng viên.

Exit code `1` khi có lỗi ở nhóm 1, 2 hoặc 4.

## 2. Phân loại kết quả

- **Phải sửa** (nhóm 1, 2, 4): thiếu key, key không tồn tại, placeholder lệch.
- **Nên xem** (nhóm 3): key thừa — đề xuất xóa nhưng không tự xóa.
- **Cần phán đoán** (nhóm 5): bỏ qua ví dụ placeholder của input (`DD/MM/YYYY`, `hello@example.com`), tên ngôn ngữ ("English", "Tiếng Việt"), tên riêng/brand, định dạng kỹ thuật. Chỉ báo những chuỗi người dùng thật sự đọc.

## 3. Báo cáo

Trình bày ngắn gọn:
- Lỗi phải sửa: `key` — vấn đề — `file:line` (nếu có).
- Đề xuất bản dịch cho key thiếu (EN ↔ VI), đúng giọng văn các key gần đó.
- Số key thừa và nhóm lớn nhất (theo namespace) để tôi quyết định dọn.
- Hard-code đáng dịch kèm key đề xuất theo namespace của màn hình.

## 4. Sửa (chỉ khi tôi yêu cầu hoặc gọi với `--fix`)

- Thêm key vào **cả hai** file, giữ cấu trúc lồng nhau và thứ tự gần key liên quan; giữ indent 4 spaces như file hiện có.
- Hard-code → thay bằng `'<namespace>.<key>'.tr()` (dùng `args:` cho giá trị động), không đổi layout.
- Không xóa key thừa nếu chưa được xác nhận.
- Chạy lại script, đảm bảo nhóm 1, 2, 4 sạch; rồi `dart format .` và `flutter analyze`.

## Lưu ý

- Key được chia sẻ giữa nhiều màn hình thì để ở `common.*`.
- Đừng ghép chuỗi bằng `+`; dùng placeholder trong bản dịch để dịch được thứ tự từ.
- Script chỉ đọc `lib/` và `assets/translations/`; chạy từ thư mục gốc project.
