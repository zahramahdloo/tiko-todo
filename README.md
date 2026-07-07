# Tiko Todo

[![Flutter CI](https://github.com/zahramahdloo/tiko-todo/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/zahramahdloo/tiko-todo/actions/workflows/flutter_ci.yml)

Tiko Todo is a Persian-first Flutter task-management app built as a portfolio project. It combines a polished mobile UI with Supabase authentication, user-scoped cloud storage, local reminders, BLoC state management, and a feature-first Clean Architecture structure.

## Screenshots

Add app screenshots to `docs/screenshots/` and reference them here.

```md
![Home](docs/screenshots/home.png)
![Timetable](docs/screenshots/timetable.png)
![Archive](docs/screenshots/archive.png)
![Settings](docs/screenshots/settings.png)
```

## Highlights

- Email/password authentication with Supabase
- User-scoped todo data protected by Supabase Row Level Security
- Create, update, delete, archive, and inspect completed tasks
- Statuses, priorities, categories, due dates, reminders, and subtasks
- Timeline view for scheduled tasks
- Archive view grouped by repeated completed task titles
- Search, filtering, sorting, and quick theme switching
- Local notification scheduling for reminders
- Persian-first UI with Flutter localization
- Clean Architecture, BLoC, dependency injection, and testable data mapping

## Tech Stack

- Flutter and Dart
- Supabase / Supabase Flutter
- flutter_bloc
- get_it
- go_router
- flutter_local_notifications
- shared_preferences

## Architecture

```text
lib/
  core/
    account/            Account/session settings
    config/             Build-time environment configuration
    di/                 Dependency injection
    error/              App-level failures
    notifications/      Local notification service
    router/             go_router configuration
    theme/              Light/dark themes
    utils/              Shared formatting helpers
    widgets/            Shared UI components
  features/
    account/
      presentation/     Authentication UI
    settings/
      presentation/     Profile and app preferences
    todo/
      data/             Supabase data sources, DTOs/models, table constants
      domain/           Entities, repository contracts, use cases
      presentation/     BLoC, pages, widgets
```

See [docs/architecture.md](docs/architecture.md) for the dependency rule and data flow.

## Supabase Setup

1. Create a Supabase project.
2. Open the Supabase SQL Editor.
3. Run [docs/supabase_schema.sql](docs/supabase_schema.sql).
4. Enable email/password authentication in Supabase Auth.

## Run Locally

Install dependencies:

```bash
flutter pub get
```

Create a local `.env` file from `.env.example` and fill in your Supabase values:

```bash
cp .env.example .env
```

Run the app:

```bash
flutter run --dart-define-from-file=.env
```

You can also pass values directly:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-supabase-publishable-key
```

## Quality Checks

```bash
dart format .
flutter analyze
flutter test
```

The GitHub Actions workflow runs formatting, analysis, and tests on pushes and pull requests to `main`.

## Android Release Build

Create `android/key.properties` from `android/key.properties.example` and keep the real file private.

```bash
flutter build apk --release --dart-define-from-file=.env
```

## Security Notes

- Real `.env` files, signing keys, APK/AAB outputs, and local build folders are ignored.
- The Supabase publishable key is provided at build/run time and is not committed to source.
- Row Level Security ensures each authenticated user can access only their own todos.
