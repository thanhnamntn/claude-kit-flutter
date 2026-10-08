---
description: Fix bug theo workflow plan → test tái hiện → code → test → review (tối đa 2 vòng sửa)
argument-hint: "<mô tả bug / file / bước tái hiện>"
---

Bug cần fix: `$ARGUMENTS`

Nếu mô tả quá mơ hồ để xác định chỗ nghi vấn, hỏi lại một lần rồi mới bắt đầu.

Dùng các subagent `plan`, `code`, `test`, `review` (`.claude/agents/`) theo thứ tự dưới đây. Chỉ `code` được sửa source. Mỗi agent kết thúc bằng `AGENT_STATUS`; dựa vào đó để quyết định bước tiếp theo.

## 1. Plan — tìm nguyên nhân gốc
Giao `plan`: xác định nguyên nhân gốc (không chỉ triệu chứng), tầng nào gây lỗi (UI/notifier/usecase/repository/datasource/mapper/BE schema), hướng sửa tối thiểu, và test nào sẽ tái hiện bug.

Nếu `NEEDS_ORCHESTRATOR` (thiếu thông tin, cần quyết định) → dừng và hỏi tôi.

## 2. Test tái hiện (trước khi sửa)
Giao `code` viết test nhỏ nhất tái hiện bug theo quy ước test của project (`.claude/rules/`), rồi giao `test` chạy để xác nhận **test fail đúng lý do**. Nếu bug thuần UI/không test được hợp lý, bỏ qua bước này và nói rõ lý do.

## 3. Code — sửa bug
Giao `code` sửa theo kế hoạch của `plan`: thay đổi tối thiểu, không refactor lan rộng, không thêm tính năng.

## 4. Test
Giao `test`: test tái hiện phải pass, rồi lint và chạy toàn bộ test (lệnh trong mục Commands của `CLAUDE.md`).

## 5. Review
Giao `review` rà diff. Với bug chạm vùng nhạy cảm (thanh toán, auth, dữ liệu người dùng), yêu cầu kiểm tra kỹ hơn.

## Vòng lặp
- `FAIL` ở bước 4 hoặc 5 → quay lại `code` với danh sách lỗi cụ thể, rồi chạy lại `test` + `review`.
- Tối đa **2 vòng** quay lại `code`. Quá giới hạn → dừng và báo tôi phần còn lại.

## Báo cáo cuối
- Nguyên nhân gốc (1–2 câu) và vì sao fix đúng chỗ.
- File đã đổi + test đã thêm.
- Kết quả `analyze`/`test`; nêu rõ nếu có bước bị bỏ qua.
- Rủi ro còn lại hoặc chỗ cần tôi kiểm tra tay (ví dụ chạy app).

Không commit; chỉ commit khi tôi yêu cầu.
