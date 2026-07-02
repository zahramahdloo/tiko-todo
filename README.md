# Tiko Todo

Tiko Todo is a Flutter task-management app built as a portfolio project. It focuses on a clean mobile experience, Supabase-backed authentication/data storage, and maintainable feature-based architecture.

## Features

- Email/password authentication with Supabase
- User-scoped todo data with Supabase Row Level Security
- Create, update, delete, archive, and restore tasks
- Task statuses, priorities, categories, due dates, reminders, and subtasks
- Search, filtering, and sorting for task lists
- Local notification scheduling for reminders
- Customizable theme mode and primary color
- Persian-first UI with Flutter localization support
- BLoC state management, dependency injection, and layered todo modules

## Tech Stack

- Flutter and Dart
- Supabase / Supabase Flutter
- flutter_bloc
- get_it
- go_router
- flutter_local_notifications
- shared_preferences

## Project Structure

```text
lib/
  core/                 Shared routing, theme, DI, account, notifications
  features/
    account/            Authentication UI
    settings/           Profile and app preferences
    todo/
      data/             Supabase data source and models
      domain/           Entities, repositories, use cases
      presentation/     BLoC, pages, widgets
```

## Getting Started

1. Install Flutter and clone the repository.
2. Install dependencies:

```bash
flutter pub get
```

3. Create a Supabase project and run the SQL in `docs/supabase_schema.sql`.
4. Run the app with your Supabase configuration:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-supabase-publishable-key
```

## Android Release Build

Create `android/key.properties` from `android/key.properties.example` and keep the real file private.

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-supabase-publishable-key
```

## Quality Checks

```bash
flutter analyze
flutter test
```

## Notes

- Real signing files, `.env` files, APK/AAB outputs, and local build folders are intentionally ignored.
- The Supabase publishable key should be provided at build/run time instead of committed directly to source.
