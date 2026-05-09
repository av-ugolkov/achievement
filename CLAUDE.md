# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Achievement** is a Flutter mobile application for tracking personal achievements. Users can create achievements with reminders, track progress, and organize them by state (active, finished, archived). The app uses local SQLite storage and supports push notifications.

- **Environment**: Flutter 3.41.9, Dart 3.11.5
- **Target Platform**: Android and iOS mobile apps
- **Localization**: Russian (ru) with flutter_intl for i18n support

## Common Commands

### Building & Running

```bash
# Debug build and run (Android)
flutter run

# Build release APK
flutter build apk --release

# Build iOS app
flutter build ios

# Clean build cache
flutter clean
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test
```

### Localization

```bash
# Generate localization files (after editing .arb files)
flutter pub run intl_utils:generate

# The project uses flutter_intl plugin — localization strings are in l10n/ directory
# Generated code is in lib/generated/intl/ — DO NOT EDIT MANUALLY
```

### Database

```bash
# The app uses sqflite (SQLite for Flutter) — database is local to the device
# No migrations needed currently; schema creation is in lib/db/ classes
```

## Architecture Overview

### Directory Structure

```
lib/
├── main.dart                 # App entry point, MaterialApp setup
├── bloc/                     # Custom BLOC pattern (stream-based state management)
│   ├── bloc_base.dart       # Abstract base for all BLOCs
│   ├── bloc_provider.dart   # Widget provider for dependency injection
│   └── bloc_achievement_state.dart  # Achievement state management
├── core/                     # Core utilities and shared logic
│   ├── data_application.dart # Reads app metadata from pubspec.yaml
│   ├── enums.dart           # AchievementState, TypeRepition enums
│   ├── event.dart           # Generic event/handler pattern
│   ├── extensions.dart      # BuildContext & DateTime extensions
│   ├── page_manager.dart    # Page navigation with notification support
│   ├── page_routes.dart     # Route constants
│   ├── notification/        # Local notifications & deep linking
│   └── utils.dart           # Global helpers (documents directory)
├── data/                     # Data models and entities
│   ├── model/               # Serializable models (fromJson/toJson)
│   │   ├── achievement_model.dart
│   │   ├── remind_model.dart
│   │   └── progress_model.dart
│   └── entities/            # Base entity classes
├── db/                       # Database access layer
│   ├── db_file.dart         # SQLite initialization and versioning
│   ├── db_achievement.dart  # CRUD operations for achievements
│   ├── db_progress.dart     # Progress tracking entries
│   └── db_remind.dart       # Reminders/notifications
├── ui/                       # UI pages and widgets
│   ├── achievements_page/   # Main list of achievements (home)
│   ├── edit_achievement_page/    # Create/edit achievement form
│   ├── view_achievement_page/    # Achievement details view
│   ├── settings_page/       # App settings
│   ├── about_page/          # About screen
│   └── common/              # Shared widgets
├── bridge/                   # Adaptation/localization bridge
│   └── localization.dart    # Helpers to access S (localization)
├── user/                     # User configuration
│   └── config.dart          # App version and locale settings
└── generated/               # GENERATED — do not edit
    ├── l10n.dart            # Localization delegate (generated)
    └── intl/                # Translated messages (generated)
```

## State Management Pattern

This app uses a **custom BLOC pattern** with streams (not Provider, GetX, or Riverpod):

1. **BlocBase**: Abstract class all BLOCs inherit from (requires `dispose()` method)
2. **BlocProvider**: StatefulWidget that wraps child with a BLOC instance
3. **BlocAchievementState**: Manages achievement list state via StreamControllers

Example usage:
```dart
// Access BLOC from context
var bloc = BlocProvider.of<BlocAchievementState>(context);

// Subscribe to state changes
bloc.outState.listen((state) { /* rebuild */ });

// Send events
bloc.inEvent.add(state);
```

**Note**: This is a legacy BLOC implementation. Consider migrating to `bloc` package for larger changes, but maintain current pattern for consistency.

## Data Flow

1. **UI Pages** → Call database (`DbAchievement`, `DbProgress`, `DbRemind`)
2. **BLOC** → Holds state, listens to events via StreamControllers
3. **Database Layer** → Direct SQLite operations via sqflite
4. **Models** → `AchievementModel`, `RemindModel`, `ProgressModel` handle serialization

No repository layer or dependency injection framework — everything is instantiated directly.

## Key Dependencies

- **sqflite**: Local SQLite database
- **flutter_local_notifications**: Push notifications and reminders
- **image_picker**: Select images for achievement icons
- **url_launcher**: Open links (used in about page)
- **path_provider**: Access device documents directory
- **intl**: Internationalization (paired with flutter_intl plugin)
- **heatmap_calendar**: Custom calendar widget (from git repo)
- **flutter_lints**: Linting rules

## Database Schema

Three main tables in SQLite:

1. **AchievementDB**: Main achievements with header, description, images, dates
2. **RemindDB**: Reminder entries (date, recurrence type)
3. **ProgressDB**: Progress tracking descriptions

Database file lives in `getApplicationDocumentsDirectory()` as managed by sqflite.

## Localization (i18n)

- Default locale: Russian (`ru`)
- Localization files in `l10n/` directory (`.arb` format)
- Generated code is in `lib/generated/intl/` — **never edit manually**
- Access strings: `S.of(context).someString` or `S.current.someString`
- Use `localization.dart` bridge for consistent access

## Navigation

- Route constants defined in `page_routes.dart`
- Manual route definitions in `main.dart` via `MaterialApp.routes`
- Deep linking via notifications routed through `PageManager`
- Payload format: JSON with `command` and achievement `id`

## Notifications

- `LocalNotification` manages Flutter Local Notifications plugin setup
- Supports scheduled/periodic reminders based on `TypeRepition` (none, day, week)
- Deep linking: tapping notification navigates to achievement details
- Payload structure: `{ "command": String, "id": int }` (JSON serialized)

## Testing

No test files currently exist. When adding tests:
- Use `flutter_test` for widget tests
- Follow Dart/Flutter testing conventions
- Run with `flutter test`

## Linting & Formatting

- Uses `flutter_lints` (flutter.yaml rules)
- Run `flutter analyze` to check for issues
- Some known lint warnings (use_super_parameters, constant_identifier_names) are low priority
- Run `dart format lib/` before commits

## Important Notes

- **No null safety issues**: Project uses null-safe Dart (non-nullable by default)
- **Image handling**: Images are stored as `List<int>` (bytes) in memory; file paths persist to documents directory
- **Timezone**: `TZDateTime` class exists but timezone package isn't in pubspec — likely unused or for future use
- **Configuration**: `Config` class in `lib/user/config.dart` centralizes app version and locale
- **Global state**: `docsDir` in `utils.dart` is set at app startup — use for file operations

## Dart Style Conventions

- Follow `dart format` output
- Use const constructors where possible
- Prefer named parameters in constructors
- Use extensions for context helpers (`scHeight`, `scWidth`, `sw600`)
- Avoid function literals in `forEach` — use for-in loops instead

## Common Workflow

1. **Add new achievement field**: Update `AchievementModel` → `AchievementEntity` → Database schema in `DbAchievement`
2. **Add new reminder type**: Update `TypeRepition` enum → `DbRemind` → UI components
3. **Add new page**: Create page in `ui/` → Add route constant → Register in `main.dart` routes
4. **Update localization**: Edit `l10n/*.arb` → Run `flutter pub run intl_utils:generate`
5. **Deploy**: `flutter build apk --release` or `flutter build ios`
