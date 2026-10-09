## Directory structure

```
lib/
├── core/
│   ├── auth/                          # Auth logic (connector, service, provider) — no UI
│   ├── config/                        # AppConfig, environment vars
│   ├── errors/                        # Failure classes
│   ├── navigation/                    # Navigator key, page route transition
│   ├── network/                       # API client setup
│   ├── utils/                         # Pure Dart helpers used by every layer (toTitleCase...)
│   ├── validators/                    # Shared pure Dart validators (phone, email, date, card); no translation, no Flutter imports
│   └── providers/                     # Data/domain wiring (split by kind)
│       ├── datasource/                # <name>_data_source_provider.dart
│       ├── repository/                # <name>_repository_provider.dart
│       ├── usecase/                   # <verb>_<name>_usecase_provider.dart
│       └── index.dart                 # Barrel export of the providers
│
├── data/
│   ├── datasources/                   # DataSource interfaces + implementations (named after the data source)
│   │   ├── <name>_datasource.dart              # Interface (returns Model)
│   │   ├── <name>_datasource_impl.dart         # Real source (GraphQL/REST)
│   │   ├── <name>_mock_datasource_impl.dart    # Mock source
│   │   └── <name>_hardcoded_datasource_impl.dart  # Hardcoded data inside the app
│   ├── graphql/                       # GraphQL queries, mutations, subscriptions
│   ├── mappers/                       # Model → Entity mapping
│   │   └── <name>_mapper.dart
│   ├── models/                        # BE response models (fromJson/toJson only)
│   └── repositories/                  # Repository implementations
├── domain/                            # Pure Dart, does NOT import data/
│   ├── entities/                      # Domain entities (<name>_entity.dart)
│   ├── enums/                         # Shared enums
│   ├── params/                        # Input Params/Requests of UseCases & Repositories (Equatable)
│   ├── repositories/                  # Repository interfaces (take/return Entities)
│   ├── usecases/                      # UseCase implementations
│   └── validators/                    # Pure Dart validators (phone, email, date, card...), return bool, no .tr()
│
├── environment/
│   ├── index.dart                     # Barrel export of the environments
│   ├── local.dart                     # Local: dev machine IP, mock auth
│   ├── dev.dart                       # Dev/staging
│   └── production.dart                # Production
│
├── features/
│   ├── <feature>/                     # Each feature is an independent module (e.g. orders, profile...)
│   │   ├── pages/                     # Pages (UI, display-only)
│   │   ├── notifiers/                 # NotifierProviders (logic + state transitions)
│   │   ├── state/                     # sealed class states for the notifier
│   │   └── widgets/                   # Feature-specific widgets
│   └── shell/                         # Shared app shell: widgets/ (app_header, app_footer, base_screen)
│
├── share/
│   ├── providers/                     # Shared Riverpod providers (e.g. selected store)
│   ├── theme/                         # Theme, colors
│   ├── utils/                         # UI utilities: format, responsive, show_message...
│   └── widgets/                       # Reusable UI components (including require_login)
│
├── main.dart
└── app_routes.dart
```