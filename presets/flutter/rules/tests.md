---
paths:
  - "test/**"
---

# Test rules

- `test/` mirror `lib/`: cùng path, thêm hậu tố `_test.dart`.
- Dùng `flutter_test` + `mocktail` (không code generation): `class MockXxx extends Mock implements Xxx {}`.
- Ưu tiên: UseCase → Mapper → RepositoryImpl → Notifier (state transitions).
- Entity không extend `Equatable`: assert qua `result.fold(...)` từng field, không so sánh cả object `Right([entity])`.
- Chạy focused trước: `flutter test <file> --plain-name "<tên test>"`, sau đó mới chạy toàn bộ.
- Tham khảo: một test usecase có sẵn trong `test/` để bắt chước style.
