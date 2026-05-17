ht# App Blocking Feature — Design Spec

**Date:** 2026-05-17  
**Branch:** check_app

## Overview

Block selected apps (e.g. YouTube) until the user has spent a configurable amount of time in the Achievement app today. When a blocked app is opened before the threshold is met, a Flutter blocker screen is shown with a progress bar and motivational message.

## Requirements

- User can mark any installed app as "blocked" (existing watchlist = block list)
- Threshold is configurable (default: 60 minutes, options: 15, 30, 60, 90, 120 min)
- Blocking is enforced via an Android Accessibility Service (instant, no polling delay)
- When a blocked app is opened before threshold: show a Flutter blocker screen
- Blocker screen shows: progress bar, remaining minutes, motivational text, back button
- When threshold is reached during the day, apps unblock automatically
- At the start of a new day, blocking resets naturally (app_usage resets)

## Architecture

### Data Flow

```
Flutter side                         Kotlin side
─────────────────────────────────    ──────────────────────────────────
AppUsageService.fetchTodayUsage()    BlockAccessibilityService
  └─ writes achievement_usage_min      └─ onAccessibilityEvent()
       to SharedPreferences                  │
                                             ▼
BlocAppUsage.toggleWatch()           reads SharedPreferences:
  └─ writes blocklist JSON             • blocklist (JSON)
       to SharedPreferences            • threshold_minutes
                                       • achievement_usage_minutes
                                             │
AppUsagePage (settings)              if blocked app + usage < threshold:
  └─ threshold picker                   startActivity(Achievement /blocker)
  └─ accessibility enable nudge

BlockerPage (/blocker route)
  └─ reads progress from SharedPreferences
  └─ shows motivational UI
  └─ back button → home screen
```

### SharedPreferences Keys

| Key | Type | Written by | Read by |
|-----|------|-----------|---------|
| `block_list` | JSON string (list of packageNames) | Flutter (BlocAppUsage) | Kotlin service |
| `threshold_minutes` | int | Flutter (AppUsagePage) | Kotlin service + BlockerPage |
| `achievement_usage_minutes` | int | Flutter (AppUsageService) | Kotlin service + BlockerPage |

## Components

### New Files

**`android/app/src/main/kotlin/.../BlockAccessibilityService.kt`**  
Extends `AccessibilityService`. Listens for `TYPE_WINDOW_STATE_CHANGED`. Reads SharedPreferences on each event, compares packageName against block list, checks usage vs threshold. If blocked: calls `startActivity` with Achievement app + `extra: route=/blocker`.

**`lib/ui/blocker_page/blocker_page.dart`**  
Flutter screen shown when a blocked app is intercepted:
- App name that was blocked (passed via intent extra)
- Progress bar: `achievement_usage_minutes / threshold_minutes`
- Text: "Осталось X минут до разблокировки"
- Motivational message
- Button: "На главную" → sends user to home screen

**`lib/core/services/block_sync_service.dart`**  
Utility class wrapping `shared_preferences` writes:
- `writeBlockList(List<String> packages)`
- `writeThreshold(int minutes)`
- `writeAchievementUsage(int minutes)`

### Modified Files

**`lib/core/services/app_usage_service.dart`**  
After `fetchTodayUsage()`, write achievement app's usage minutes to SharedPreferences via `BlockSyncService`.

**`lib/bloc/bloc_app_usage.dart`**  
`toggleWatch()` additionally calls `BlockSyncService.writeBlockList()`.  
Add `setThreshold(int minutes)` method that saves to prefs and triggers state update.

**`lib/ui/app_usage_page/app_usage_page.dart`**  
- Add threshold selector (DropdownButton: 15, 30, 60, 90, 120 min)
- Add accessibility service status banner with "Включить" button when service is not active
- Rename bookmark icon tooltip/semantics to reflect "blocking" meaning

**`lib/main.dart`**  
- Register `/blocker` route
- On app start, check for intent extra `route=/blocker` and navigate accordingly

**`android/app/src/main/AndroidManifest.xml`**  
Register `BlockAccessibilityService` with required intent filter and meta-data pointing to accessibility service config XML.

**`android/app/src/main/res/xml/accessibility_service_config.xml`** (new)  
Accessibility service configuration: `accessibilityEventTypes`, `accessibilityFeedbackType`, `canRetrieveWindowContent`.

## Permissions

| Permission | How obtained |
|-----------|-------------|
| `PACKAGE_USAGE_STATS` | Already in use |
| `BIND_ACCESSIBILITY_SERVICE` | User enables manually in Android Settings → Accessibility |

## Edge Cases

| Scenario | Behavior |
|---------|---------|
| Accessibility service not enabled | Banner in AppUsagePage with link to Settings |
| Achievement app itself is opened | Service ignores its own package name |
| Threshold reached mid-day | Next event from service: usage ≥ threshold → no block |
| New day | app_usage naturally resets; blocking active again |
| Flutter process killed | Kotlin service continues independently |
| Blocked app not in foreground (notification shade, etc.) | Service only acts on `packageName` changes; ignores system UI |

## UX Flow

```
User opens YouTube
       │
BlockAccessibilityService fires
       │
packageName in block_list? ──No──► allow
       │ Yes
achievement_usage < threshold? ──No──► allow
       │ Yes
startActivity(Achievement, extra: blocked_pkg=com.google.youtube)
       │
BlockerPage shown:
  [YouTube] заблокирован
  ████████░░░░░ 45/60 мин
  Осталось 15 минут
  [На главную]
```

## Dependencies to Add

- `shared_preferences: ^2.x` — for SharedPreferences access from Dart side (not yet in pubspec.yaml)

## Package Names

- Achievement app: `com.ugolkov.achievement` — Kotlin service must ignore this package
- Achievement app usage: extracted from `fetchTodayUsage()` result by matching package name `com.ugolkov.achievement`, then filtered out of the displayed list in `AppUsagePage`
