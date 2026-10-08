# claude-kit

Bộ `.claude/` dùng lại cho nhiều project: agents, commands, skills, rules. Cài bằng một lệnh, rồi chỉnh vài chỗ riêng của project.

```
claude-kit/
├── install.sh
├── core/                          # không phụ thuộc stack
│   ├── agents/                    # plan, code, review, test (kết thúc bằng AGENT_STATUS)
│   ├── commands/                  # check, fix-bug, review-rules
│   ├── skills/
│   │   ├── commit/                # commit đúng quy ước git, --split / --push
│   │   └── create-pr/             # main pull --rebase -> rebase nhánh lên main -> push -> PR
│   ├── rules/git.md               # tên nhánh, commit, nhánh mới luôn từ main đã cập nhật
│   ├── settings.json              # quyền git read-only
│   └── CLAUDE.md.template
└── presets/
    └── flutter/                   # Clean Architecture + Riverpod
        ├── rules/                 # presentation, domain-entities, data-layer, imports, structure, tests
        ├── commands/              # check, review-rules, new-feature (ghi đè core)
        ├── skills/
        │   ├── refactor-to-pattern/
        │   └── check-translations/    # script kiểm tra en/vi (cần assets/translations/*.json)
        ├── scripts/check_structure.sh # barrel, import tương đối, hướng phụ thuộc, khớp STRUCTURE.md
        ├── STRUCTURE.md           # mẫu cây lib/ (chuyển ra gốc project khi cài)
        └── CLAUDE.md.fragment
```

## Cài vào project

```bash
./install.sh ~/path/to/project                    # chỉ core
./install.sh ~/path/to/project --preset flutter   # core + Flutter
./install.sh ~/path/to/project --force            # ghi đè file đã có
```

- Không ghi đè file đã có (trừ `--force`); file preset đã bị người dùng sửa cũng được giữ.
- `CLAUDE.md` không bao giờ bị ghi đè: nếu đã có, bản mẫu ghi ra `CLAUDE.md.kit-new` để gộp tay.
- `STRUCTURE.md` được chuyển ra thư mục gốc project (nếu chưa có). `check_structure.sh` nằm ở `.claude/scripts/`.

## Sau khi cài (bắt buộc)

1. **Git:** trong `.claude/rules/git.md`, `skills/commit`, `skills/create-pr` thay `<app>` / `{tên-dự-án}` bằng tên project (nhánh `{loại}/<app>/<việc>`, commit `{loại}(<app>): ...`).
2. **`CLAUDE.md`:** điền tổng quan, **Commands** (agent `test` và `/check` đọc lệnh từ đây), kiến trúc.
3. **`paths:` trong `.claude/rules/*.md`:** chỉnh cho khớp thư mục thật.
4. **Preset Flutter:** preset giả định cây `lib/{core,data,domain,features,share}` và feature gồm `pages/ notifiers/ state/ widgets/`. Project khác cấu trúc thì sửa `STRUCTURE.md` và `scripts/check_structure.sh` (script sẽ báo lỗi nếu lệch). Import ví dụ dùng `package:<app>/...`.
5. **`.claude/settings.json`:** thêm quyền Bash cần dùng (ví dụ `Bash(flutter *)`, `Bash(dart *)`).
6. Thêm rule riêng của project (nghiệp vụ nhạy cảm, API, thanh toán...) vào `.claude/rules/`.
7. Chạy `bash .claude/scripts/check_structure.sh` để xem project lệch chuẩn ở đâu.

## Quy ước kit đang áp dụng

- Nhánh mới luôn tạo từ `main` sau `checkout main` + `pull --rebase origin main`.
- `/create-pr`: rebase **nhánh làm việc lên main** (`git rebase main`), không merge main vào nhánh; force-with-lease chỉ khi tôi xác nhận.
- Commit không có `Co-Authored-By`; mô tả commit/PR bằng tiếng Anh. Comment trong code bằng tiếng Anh.
- Đổi cây thư mục thì cập nhật `STRUCTURE.md` trong cùng commit (rule `structure.md`).
- Tách rule: `core/` không có rule nghiệp vụ; mỗi project tự thêm.

## Cập nhật kit

Sửa rule/skill trong project thật trước, kiểm chứng, rồi copy phần chung ngược về `core/` hoặc `presets/<stack>/` (giữ tên project dạng `<app>`). Project đã cài không tự cập nhật: chạy lại `install.sh --force` hoặc gộp tay.
