## Cấu trúc thư mục

```
lib/
├── core/
│   ├── auth/                          # Auth logic (connector, service, provider) — không có UI
│   ├── config/                        # AppConfig, environment vars
│   ├── errors/                        # Failure classes
│   ├── navigation/                    # Navigator key, page route transition
│   ├── network/                       # API client setup
│   ├── utils/                         # Helper thuần Dart dùng cho mọi tầng (toTitleCase...)
│   └── providers/                     # Wiring data/domain (chia theo loại)
│       ├── datasource/                # <name>_data_source_provider.dart
│       ├── repository/                # <name>_repository_provider.dart
│       ├── usecase/                   # <verb>_<name>_usecase_provider.dart
│       └── index.dart                 # Barrel export các provider
│
├── data/
│   ├── datasources/                   # DataSource interface + implementations (đặt tên theo nguồn dữ liệu)
│   │   ├── <name>_datasource.dart              # Interface (trả Model)
│   │   ├── <name>_datasource_impl.dart         # Nguồn thật (GraphQL/REST)
│   │   ├── <name>_mock_datasource_impl.dart    # Nguồn mock
│   │   └── <name>_hardcoded_datasource_impl.dart  # Dữ liệu hardcode trong app
│   ├── graphql/                       # GraphQL queries, mutations, subscriptions
│   ├── mappers/                       # Model → Entity mapping
│   │   └── <name>_mapper.dart
│   ├── models/                        # BE response models (fromJson/toJson only)
│   └── repositories/                  # Repository implementations
├── domain/                            # Pure Dart, KHÔNG import data/
│   ├── entities/                      # Domain entities (<name>_entity.dart)
│   ├── enums/                         # Enum dùng chung
│   ├── params/                        # Params/Request đầu vào của UseCase & Repository (Equatable)
│   ├── repositories/                  # Repository interfaces (nhận/trả Entity)
│   └── usecases/                      # UseCase implementations
│
├── environment/
│   ├── index.dart                     # Barrel export các environment
│   ├── local.dart                     # Local: IP máy dev, mock auth
│   ├── dev.dart                       # Dev/staging
│   └── production.dart                # Production
│
├── features/
│   ├── <feature>/                     # Mỗi feature là 1 module độc lập (ví dụ: orders, profile...)
│   │   ├── pages/                     # Page (UI, display-only)
│   │   ├── notifiers/                 # NotifierProvider (logic + state transitions)
│   │   ├── state/                     # sealed class state cho notifier
│   │   └── widgets/                   # Widget riêng của feature
│   └── shell/                         # Khung app dùng chung: widgets/ (app_header, app_footer, base_screen)
│
├── share/
│   ├── providers/                     # Shared Riverpod providers (vd selected store)
│   ├── theme/                         # Theme, colors
│   ├── utils/                         # Tiện ích UI: format, responsive, show_message...
│   └── widgets/                       # Reusable UI components (kể cả require_login)
│
├── main.dart
└── app_routes.dart
```