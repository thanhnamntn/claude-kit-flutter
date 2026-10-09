---
paths:
  - "lib/domain/**"
---

# Domain layer rules

- The domain is pure Dart: no Flutter imports and **no `lib/data/**` imports** (Model, GraphQL, DataSource live in the data layer).
- Entity: `Entity` suffix, placed in `domain/entities/`, does not import Models.
- Models (`data/models/`) only mirror the BE response with `fromJson`/`toJson`; only the data layer (DataSource, RepositoryImpl, Mapper) may use Models. Mappers convert Model → Entity.
- DataSource interfaces (`data/datasources/`) return Models; Repository interfaces (domain) and UseCases only take/return Entities or domain-defined Params, as `Either<Failure, Entity>`.
- Params (`XxxParams extends Equatable`) go in `domain/params/`, not in the usecase file — repository interfaces use them too, so `repositories` and `usecases` do not import each other.
- UseCase: a single responsibility, returns `Either<Failure, T>`. Named with the standard verbs (see the Naming section in `data-layer.md`).
- Enums (`domain/enums/`) only declare values and helpers independent of the BE. Conversion to/from BE strings (`toGraphQL`/`fromGraphQL`) lives in `data/mappers/enum_graphql_mapper.dart`; the domain and features use enums, never pass BE strings. Pure UI enums (e.g. navigation tabs) live in the feature that uses them.
- Do not throw raw exceptions; use `Either<Failure, T>`.
- Do not use the `k` prefix for constants.
- Validators go in `domain/validators/` (pure Dart functions or classes, return `bool`, no `.tr()`, no Flutter; take `now` if time is needed). Validators shared by many screens and independent of any entity (phone, email, date, card) use one file per concern, e.g. `phone_validator.dart`. Rules tightly bound to one entity are written in the entity/rules class in `domain/entities/`. Error messages are translated in the notifier/UI, not in the validator. Features call validators directly (domain is importable from `features/`).
