---
paths:
  - "test/**"
---

# Test rules

- `test/` mirrors `lib/`: same path, with the `_test.dart` suffix.
- Use `flutter_test` + `mocktail` (no code generation): `class MockXxx extends Mock implements Xxx {}`.
- Priority: UseCase → Mapper → RepositoryImpl → Notifier (state transitions).
- Entities do not extend `Equatable`: assert via `result.fold(...)` field by field, do not compare whole `Right([entity])` objects.
- Run focused first: `flutter test <file> --plain-name "<test name>"`, then run the full suite.
- Reference: an existing usecase test in `test/` to mimic its style.
