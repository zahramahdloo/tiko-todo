# Architecture

Tiko follows a feature-first Clean Architecture style. The `todo` feature is split into `data`, `domain`, and `presentation` layers so business rules stay independent from Flutter and Supabase.

## Layers

- `domain`: entities, repository contracts, and use cases. This layer is pure Dart and has no Flutter, Supabase, or UI dependencies.
- `data`: Supabase data source implementations, database table constants, DTO/model mapping, and repository implementations.
- `presentation`: BLoC state management, pages, widgets, and UI-only formatting/interactions.
- `core`: app-wide concerns such as routing, dependency injection, build-time config, theme, notifications, account settings, errors, and shared widgets.

## Dependency Rule

Dependencies point inward:

```text
presentation -> domain
data         -> domain
core         -> shared app services only
```

The presentation layer calls use cases. Use cases call repository contracts. The data layer implements those contracts and maps Supabase rows to domain entities.

## Data Flow

```text
UI event
  -> TodoBloc
  -> UseCase
  -> TodoRepository
  -> TodoRemoteDataSource
  -> Supabase
```

Responses flow back as domain entities, keeping UI code free of raw database maps.

## Supabase

The SQL schema lives in `docs/supabase_schema.sql`. Row Level Security keeps todos scoped to the authenticated user. Database table and column names are centralized in `TodoTable` under the todo data layer, keeping Supabase-specific schema details out of `domain` and `presentation`.
