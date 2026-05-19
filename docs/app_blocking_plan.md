# App-Blocking Module — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a full app-blocking feature to the Achievement Flutter app: users select apps to block, define an unlock condition (initially "spend X minutes in a chosen target app"), and blocked apps are intercepted on Android via AccessibilityService until the condition is met for the current day.

**Architecture:** Three layers — (1) Android native layer (`BlockAccessibilityService.kt`, `MainActivity.kt`) detects foreground app changes and fires the blocker intent; (2) a Dart service + BLOC layer manages state, SQLite persistence, and SharedPreferences sync; (3) UI screens let users pick apps to block, configure the unlock condition, and see blocking/unlock feedback. The condition system is designed as a sealed class hierarchy so future condition types can be added by extending one file.

**Tech Stack:** Flutter 3.41.9, Dart 3.11.5, sqflite (SQLite), shared_preferences (native bridge), app_usage (UsageStats API), installed_apps (package list), workmanager (background sync), AccessibilityService (Kotlin), MethodChannel `com.ugolkov.achievement/blocker`.

---

## What Already Exists (Do Not Rewrite)

Before implementing, understand what is already in place:

| File | Role |
|---|---|
| `android/…/BlockAccessibilityService.kt` | Detects foreground app; if in block list AND threshold not met → calls `launchBlocker()` |
| `android/…/MainActivity.kt` | MethodChannel handler: `getPendingBlockedPackage`, `isAccessibilityEnabled`, `openAccessibilitySettings` |
| `lib/core/services/block_sync_service.dart` | Reads/writes `block_list`, `threshold_minutes`, `achievement_usage_minutes` to SharedPreferences |
| `lib/core/services/app_usage_service.dart` | Reads today's usage via `app_usage`, fetches installed apps, saves/loads `watchlist.json` |
| `lib/core/services/background_watch_service.dart` | Workmanager background task: re-syncs block list + achievement usage every 15 min |
| `lib/bloc/bloc_app_usage.dart` | Stream-based BLOC: `AppUsageStateLoading`, `AppUsageStateLoaded`, `AppUsageStatePermissionDenied`, `AppUsageStateError` |
| `lib/ui/app_usage_page/app_usage_page.dart` | App list with block toggles + threshold dropdown |
| `lib/ui/blocker_page/blocker_page.dart` | Shown when blocked app intercepted; shows progress bar toward unlock |

**Key gap identified:** The current "watched app" is hardcoded to `com.ugolkov.achievement` itself (`kAchievementPackage`). The task requires the user to choose any installed app as the unlock target. This is the central new feature.

---

## 1. Module Overview

### User-Facing Behavior

1. User opens the **App Usage** tab and taps a new **"Configure Blocking"** button or navigates to the blocking settings screen.
2. On the **App Picker** screen the user sees all installed apps (not just apps used today) and toggles which ones to block.
3. On the **Condition Configurator** screen the user selects an unlock condition type (initially only one: "Spend X minutes in [app]"), picks the target app and duration.
4. When the user opens a blocked app, the `BlockAccessibilityService` fires, presses Home, and launches `MainActivity` with a `blocked_package` extra.
5. The Flutter app navigates to **BlockerPage**, showing the current progress toward the unlock condition.
6. When the condition is satisfied (foreground time in target app ≥ threshold), the Kotlin service writes an "unlocked" flag. On the next event check it skips blocking.
7. The Flutter app detects the unlock transition and shows an **Unlock Success** screen.
8. At midnight (next calendar day) all session state resets: blocked apps are active again.

### Session Lifecycle

```
[Day starts] 
     │
     ▼
block_list written to SharedPreferences
unlocked_today = false
     │
     ▼  user opens blocked app
BlockAccessibilityService fires
     │ unlocked_today == false?
     ├─ yes → press Home + launch BlockerPage
     └─ no  → let app open
     │
     ▼  user spends time in target app
background task (15 min) + foreground timer (1 min)
updates achievement_usage_minutes (or target_app_usage_minutes)
     │
     ▼  usage >= threshold
write unlocked_today = true to SharedPreferences
     │
     ▼
Flutter shows UnlockSuccessPage
     │
     ▼  midnight (new calendar day)
reset: unlocked_today = false, usage counters = 0
```

---

## 2. UI Screens

### Navigation Flow

```
AchievementsPage (home)
  └── AppUsagePage (tab)
        ├── [Banner: Accessibility not enabled → Settings]
        ├── [Banner: Usage permission not granted → Settings]
        ├── AppPickerPage  ← new
        │     └── pick apps to block (all installed, not just used today)
        ├── ConditionConfigPage  ← new
        │     └── choose condition type + target app + threshold
        └── BlockerPage (shown via deep-link when blocked app launched)
              └── UnlockSuccessPage  ← new
```

### Screen Inventory

#### 1. `AppUsagePage` (existing — minor additions)

**Route:** displayed as bottom-nav tab, no route constant needed  
**Changes:**
- Add two action buttons in the `AppBar`: "Blocked Apps" → `AppPickerPage`, "Unlock Rule" → `ConditionConfigPage`
- Remove the `_ThresholdSelector` widget (moved to `ConditionConfigPage`)
- Keep the app usage list + block toggles (toggles now write to `BlockedAppDB` via `BlocBlockingConfig`)

#### 2. `AppPickerPage` (new)

**Route:** `/app_picker` (add to `page_routes.dart` + `main.dart`)  
**File:** `lib/ui/app_picker_page/app_picker_page.dart`

Shows **all installed apps** (via `InstalledApps.getInstalledApps(true, true)` — includes system apps filtered by having a launch intent), not just apps with usage today. Search bar at the top. Each row has an app icon, name, package name, and a block/unblock toggle.

**State source:** `BlocBlockingConfig.outState` → `BlockingConfigLoaded.blockedApps`

**Key behavior:**
- Toggling an app calls `BlocBlockingConfig.addBlockedApp` / `removeBlockedApp`
- The Achievement app itself (`com.ugolkov.achievement`) cannot be added to the block list (filter it out)
- Search filters by app name (case-insensitive)

#### 3. `ConditionConfigPage` (new)

**Route:** `/condition_config`  
**File:** `lib/ui/condition_config_page/condition_config_page.dart`

**Layout:**
1. **Condition type selector** — initially only one option: "Spend time in an app". Displayed as a `SegmentedButton` or `RadioListTile` group. (Second option placeholder: "Time of day" — disabled, shown greyed out with "Coming soon" label.)
2. **Target app picker** — a `ListTile` showing the currently selected target app (name + icon). Tapping opens an app picker bottom sheet (reuses installed apps list, filtered to exclude the block list).
3. **Threshold slider** — integer slider from 5 to 180 minutes in 5-minute steps. Shows current value as `N minutes`.
4. **Save button** — calls `BlocBlockingConfig.setUnlockCondition(...)`, pops back.

#### 4. `BlockerPage` (existing — enhance)

**Route:** `/blocker`  
**File:** `lib/ui/blocker_page/blocker_page.dart`

**Existing behavior:** Shows lock icon, blocked package name, linear progress bar toward threshold, "Go to Home" button.

**New behavior:**
- Use `BlocUnlockProgress` for real-time progress (replaces direct `BlockSyncService` calls)
- Add a 1-minute `Timer.periodic` that fires `UnlockProgressEvent.refresh` to re-read usage from SharedPreferences
- Show target app name + icon: "Use [Target App] for [N] more minutes to unlock"
- When `UnlockProgressTracking.unlocked == true`, navigate to `UnlockSuccessPage` (replace current route)

#### 5. `UnlockSuccessPage` (new)

**Route:** `/unlock_success`  
**File:** `lib/ui/unlock_success_page/unlock_success_page.dart`

**Layout:**
- Large checkmark icon (green)
- Headline: "Apps unlocked for today!"
- Subtext: "Your blocked apps are available until midnight."
- "Continue" button → `SystemNavigator.pop()` (returns user to whatever they were doing; they can now open the previously blocked app)

No timer needed; this screen is shown once per day after the unlock condition is first met.

---

## 3. Android System Integration

### Required Permissions

```xml
<!-- AndroidManifest.xml — already present -->
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"
    tools:ignore="ProtectedPermissions" />

<!-- Not yet present — add these -->
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"
    tools:ignore="QueryAllPackagesPermission" />
```

`BIND_ACCESSIBILITY_SERVICE` is declared implicitly by the `<service>` element with `android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"` — already present.

`PACKAGE_USAGE_STATS` is already present. It requires the user to grant it manually via Settings → Apps → Special App Access → Usage Access — the existing `_AccessibilityBanner` pattern should be replicated for this permission.

`QUERY_ALL_PACKAGES` is needed for `InstalledApps.getInstalledApps()` to return all packages on Android 11+. The `<queries>` block in the manifest already covers `LAUNCHER` category intents, but the `QUERY_ALL_PACKAGES` permission gives complete results. Add it with a `tools:ignore` for Google Play review (acceptable for a personal/side-loaded app).

### Foreground Detection Flow

`BlockAccessibilityService` listens for two event types:
- `TYPE_WINDOW_STATE_CHANGED` — fires when a new Activity comes to the front (most reliable trigger)
- `TYPE_WINDOWS_CHANGED` — fires even when a backgrounded app resumes (covers cases `STATE_CHANGED` misses)

Both paths call `isInBlockList(packageName)`, then `achievementUsageMetThreshold()`. If both conditions pass (app is blocked AND threshold not yet met), `launchBlocker(packageName)` is called.

### Changes Needed in the Native Layer

#### `BlockAccessibilityService.kt` — replace `achievementUsageMetThreshold()` with `unlockConditionMet()`

Currently:
```kotlin
private fun achievementUsageMetThreshold(): Boolean {
    // reads flutter.achievement_usage_minutes vs flutter.threshold_minutes
    // only tracks THIS app's own usage
}
```

New behavior needed:
```kotlin
private fun unlockConditionMet(): Boolean {
    val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    // Check if day already unlocked
    val unlockedDay = prefs.getString("flutter.unlocked_day", "") ?: ""
    val today = LocalDate.now().toString()
    if (unlockedDay == today) return true

    // Condition type dispatch (extensible)
    val conditionType = prefs.getInt("flutter.unlock_condition_type", 0)
    return when (conditionType) {
        0 -> checkTimeInAppCondition(prefs, today)
        else -> false
    }
}

private fun checkTimeInAppCondition(prefs: SharedPreferences, today: String): Boolean {
    val storedDay = prefs.getString("flutter.target_usage_day", "") ?: ""
    val usage = if (storedDay == today) prefs.getInt("flutter.target_usage_minutes", 0) else 0
    val threshold = prefs.getInt("flutter.threshold_minutes", 60)
    val met = usage >= threshold
    if (met) {
        prefs.edit().putString("flutter.unlocked_day", today).apply()
    }
    return met
}
```

#### `MainActivity.kt` — add new MethodChannel methods

Add to the `when (call.method)` block:
```kotlin
"getUnlockStatus" -> {
    val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    val today = java.time.LocalDate.now().toString()
    val unlockedDay = prefs.getString("flutter.unlocked_day", "") ?: ""
    result.success(unlockedDay == today)
}
```

### How Blocking Intercepts an App Launch

1. `onAccessibilityEvent` fires with the foreground package name.
2. `isInBlockList(pkg)` checks `flutter.block_list` in SharedPreferences (JSON array of package name strings).
3. `unlockConditionMet()` checks `flutter.unlocked_day == today`.
4. If blocked and not unlocked: `performGlobalAction(GLOBAL_ACTION_HOME)` presses Home, then `startActivity(intent)` brings Achievement to the foreground with `blocked_package` extra.
5. Flutter receives the extra in `onNewIntent` → `MethodChannel.invokeMethod("showBlocker", pkg)` → app navigates to `/blocker`.

The 3-second cooldown (`cooldownMs = 3000L`) prevents re-triggering when Achievement itself changes windows.

---

## 4. iOS Limitations

**App blocking is not possible on iOS.** This is a hard platform constraint, not an implementation gap.

- iOS has no `AccessibilityService` equivalent that can monitor foreground app changes.
- iOS does not expose an API that allows one app to detect which other app is in the foreground (sandboxing prevents this).
- `Screen Time` API (`FamilyControls` framework) can impose per-app time limits, but it requires a managed device (MDM) or Family Sharing enrollment with an adult/child account pair — not suitable for a self-managed personal app.
- The `app_usage` Dart package returns `[]` on iOS (already guarded in `AppUsageService.hasPermission()` and `fetchTodayUsage()`).

**What to show iOS users:** On iOS, the App Blocking tab should display a message explaining that this feature requires Android and is not available on iOS. The UI guard is already partially in place via `Platform.isIOS` checks in `AppUsageService`; this guard should be surfaced at the tab level as well.

---

## 5. Data Model

### Current Storage Strategy

The existing feature stores data in two places:
- **File** (`watchlist.json` in documents directory) — the block list (`Map<packageName, appName>`)
- **SharedPreferences** — runtime sync values read by the Kotlin native layer

### New SQLite Tables Required

The module needs three new tables in `Achievement.db`. Add them via a schema version bump in `Config.version` (currently `1` → bump to `2`).

#### Table: `BlockedAppDB`

Stores the user's list of apps to block.

```sql
CREATE TABLE BlockedAppDB (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    package_name  TEXT    NOT NULL UNIQUE,
    app_name      TEXT    NOT NULL,
    added_date    INTEGER NOT NULL   -- milliseconds since epoch
);
```

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER | Primary key |
| `package_name` | TEXT | e.g. `com.instagram.android` |
| `app_name` | TEXT | Display name at time of adding |
| `added_date` | INTEGER | Epoch ms |

#### Table: `UnlockConditionDB`

Stores the single active unlock condition (only one active at a time in v1).

```sql
CREATE TABLE UnlockConditionDB (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    condition_type  INTEGER NOT NULL DEFAULT 0,
    target_package  TEXT    NOT NULL,
    target_app_name TEXT    NOT NULL,
    threshold_mins  INTEGER NOT NULL DEFAULT 60,
    is_active       INTEGER NOT NULL DEFAULT 1  -- 0 or 1 boolean
);
```

| Column | Type | Notes |
|---|---|---|
| `condition_type` | INTEGER | `0` = TimeInApp; extensible enum |
| `target_package` | TEXT | App the user must use to unlock |
| `target_app_name` | TEXT | Display name |
| `threshold_mins` | INTEGER | Minutes required |
| `is_active` | INTEGER | Only one condition active; 1 = active |

#### Table: `BlockSessionDB`

One row per calendar day — tracks current session state. Checked and reset at midnight.

```sql
CREATE TABLE BlockSessionDB (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    session_date    TEXT    NOT NULL UNIQUE, -- 'YYYY-MM-DD'
    unlocked        INTEGER NOT NULL DEFAULT 0, -- 0 or 1
    unlock_time     INTEGER                     -- epoch ms, null if not unlocked
);
```

| Column | Type | Notes |
|---|---|---|
| `session_date` | TEXT | `YYYY-MM-DD` string |
| `unlocked` | INTEGER | 1 once unlock condition met |
| `unlock_time` | INTEGER | When it was unlocked (nullable) |

#### Table: `UsageLogDB`

Append-only log of foreground time snapshots. Used for auditing and future condition types (e.g. step count, time-of-day).

```sql
CREATE TABLE UsageLogDB (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    package_name  TEXT    NOT NULL,
    log_date      TEXT    NOT NULL,  -- 'YYYY-MM-DD'
    minutes       INTEGER NOT NULL,
    recorded_at   INTEGER NOT NULL   -- epoch ms
);
```

| Column | Type | Notes |
|---|---|---|
| `package_name` | TEXT | Tracked app |
| `log_date` | TEXT | Calendar day |
| `minutes` | INTEGER | Cumulative minutes that day |
| `recorded_at` | INTEGER | Snapshot timestamp |

### SharedPreferences Keys (native bridge)

These are read directly by Kotlin — must use the `flutter.` prefix because SharedPreferences via the Flutter plugin writes with that prefix automatically.

| Key | Type | Written by | Read by |
|---|---|---|---|
| `flutter.block_list` | String (JSON array) | `BlockSyncService` | `BlockAccessibilityService` |
| `flutter.unlock_condition_type` | Int | `BlockSyncService` | `BlockAccessibilityService` |
| `flutter.target_package` | String | `BlockSyncService` | `BlockAccessibilityService` |
| `flutter.target_usage_day` | String | `AppUsageService` | `BlockAccessibilityService` |
| `flutter.target_usage_minutes` | Int | `AppUsageService` | `BlockAccessibilityService` |
| `flutter.threshold_minutes` | Int | `BlockSyncService` | `BlockAccessibilityService` |
| `flutter.unlocked_day` | String | `BlockAccessibilityService` | `BlockSyncService`, Flutter |

### Migration Strategy

`DbFile.initDB` passes `onUpgrade` callback. When `Config.version` goes from 1 to 2, `onUpgrade` runs the `CREATE TABLE` statements for the three new tables. Existing data is untouched.

---

## 6. BLOC Design

The app uses a **custom stream-based BLOC pattern** (not the `bloc` package). All new BLOCs follow the same structure as `BlocAchievementState` and `BlocAppUsage`:
- One `StreamController` for state (output)
- One `StreamController` for events (input)
- `inEvent` sink for callers to send events
- `outState` stream for UI to subscribe
- `dispose()` closes both controllers

### Existing BLOC: `BlocAppUsage` — Extend, Do Not Replace

`BlocAppUsage` already manages the app list with blocking toggles. Extend it with:
- `setTargetApp(String packageName, String appName)` — saves the unlock condition target
- `setConditionType(UnlockConditionType type)` — saves the condition type
- Remove the existing `setThreshold` + `toggleWatch` pairing confusion (watchlist = block list, threshold = unlock threshold)

### New BLOC: `BlocBlockingConfig`

Manages the blocking configuration (which apps are blocked + what unlock condition is set). Replaces the ad-hoc in-`BlocAppUsage` approach for condition management.

```dart
// lib/bloc/bloc_blocking_config.dart

sealed class BlockingConfigState {}
class BlockingConfigLoading extends BlockingConfigState {}
class BlockingConfigLoaded extends BlockingConfigState {
  final List<BlockedAppModel> blockedApps;
  final UnlockConditionModel? activeCondition;
  final bool sessionUnlocked;
  BlockingConfigLoaded({
    required this.blockedApps,
    required this.activeCondition,
    required this.sessionUnlocked,
  });
}
class BlockingConfigError extends BlockingConfigState {
  final String message;
  BlockingConfigError(this.message);
}

enum BlockingConfigEvent { load, refresh }

class BlocBlockingConfig extends BlocBase {
  // StreamController<BlockingConfigState> + StreamController<BlockingConfigEvent>
  // follows exact same pattern as BlocAppUsage
}
```

**Methods on `BlocBlockingConfig`:**

| Method | Purpose |
|---|---|
| `addBlockedApp(String pkg, String name)` | Inserts into `BlockedAppDB`, syncs SharedPreferences |
| `removeBlockedApp(String pkg)` | Deletes from `BlockedAppDB`, syncs SharedPreferences |
| `setUnlockCondition(UnlockConditionModel)` | Upserts `UnlockConditionDB`, syncs SharedPreferences |
| `checkSessionUnlocked()` | Reads `BlockSessionDB` for today; emits current unlock state |
| `markSessionUnlocked()` | Inserts/updates `BlockSessionDB` for today with `unlocked = 1` |

### New BLOC: `BlocUnlockProgress`

Lightweight BLOC used only by `BlockerPage` and the unlock polling logic.

```dart
// lib/bloc/bloc_unlock_progress.dart

sealed class UnlockProgressState {}
class UnlockProgressLoading extends UnlockProgressState {}
class UnlockProgressTracking extends UnlockProgressState {
  final int usageMinutes;
  final int thresholdMinutes;
  final String targetAppName;
  final bool unlocked;
  UnlockProgressTracking({...});
}

enum UnlockProgressEvent { refresh }
```

`BlocUnlockProgress` polls `BlockSyncService.readTargetUsage()` on each `refresh` event, which is fired every 60 seconds by a `Timer.periodic` inside `BlockerPage`.

---

## 7. Unlock Condition System

### Design Goal

Make it trivial to add a second condition type (e.g. "Time of day: only allow after 6 PM", "Step count: walk 5000 steps") without touching the blocking or BLOC infrastructure.

### Model

```dart
// lib/data/model/unlock_condition_model.dart

enum UnlockConditionType { timeInApp }

sealed class UnlockConditionModel {
  final int id;
  final UnlockConditionType type;
  const UnlockConditionModel({required this.id, required this.type});

  factory UnlockConditionModel.fromJson(Map<String, dynamic> map) {
    final type = UnlockConditionType.values[map['condition_type'] as int];
    return switch (type) {
      UnlockConditionType.timeInApp => TimeInAppCondition.fromJson(map),
    };
  }

  Map<String, dynamic> toJson();

  /// Returns true when this condition is currently satisfied for today.
  /// Called by BlocUnlockProgress.
  Future<bool> isSatisfied();

  /// Writes any SharedPreferences keys the Kotlin layer needs to read.
  Future<void> syncToNative(BlockSyncService sync);
}

class TimeInAppCondition extends UnlockConditionModel {
  final String targetPackage;
  final String targetAppName;
  final int thresholdMinutes;

  const TimeInAppCondition({
    required super.id,
    required this.targetPackage,
    required this.targetAppName,
    required this.thresholdMinutes,
  }) : super(type: UnlockConditionType.timeInApp);

  factory TimeInAppCondition.fromJson(Map<String, dynamic> map) => TimeInAppCondition(
    id: map['id'] as int,
    targetPackage: map['target_package'] as String,
    targetAppName: map['target_app_name'] as String,
    thresholdMinutes: map['threshold_mins'] as int,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'condition_type': type.index,
    'target_package': targetPackage,
    'target_app_name': targetAppName,
    'threshold_mins': thresholdMinutes,
    'is_active': 1,
  };

  @override
  Future<bool> isSatisfied() async {
    final sync = BlockSyncService();
    final usage = await sync.readTargetUsage();
    return usage >= thresholdMinutes;
  }

  @override
  Future<void> syncToNative(BlockSyncService sync) async {
    await sync.writeUnlockConditionType(type.index);
    await sync.writeTargetPackage(targetPackage);
    await sync.writeThreshold(thresholdMinutes);
  }
}
```

### Adding a New Condition Type

1. Add a new value to `UnlockConditionType` enum.
2. Add a new subclass of `UnlockConditionModel` implementing `isSatisfied()` and `syncToNative()`.
3. Add a `case` to `UnlockConditionModel.fromJson`.
4. Add a `case` to `BlockAccessibilityService.unlockConditionMet()` in Kotlin.
5. Add the condition's UI section to `ConditionConfigPage`.

No changes needed to BLOCs, DB classes, or the blocker flow.

### `BlockSyncService` New Methods

Add to `lib/core/services/block_sync_service.dart`:
```dart
static const _unlockConditionTypeKey = 'unlock_condition_type';
static const _targetPackageKey = 'target_package';
static const _targetUsageDayKey = 'target_usage_day';
static const _targetUsageMinutesKey = 'target_usage_minutes';
static const _unlockedDayKey = 'unlocked_day';

Future<void> writeUnlockConditionType(int type) async { ... }
Future<void> writeTargetPackage(String pkg) async { ... }
Future<void> writeTargetUsage(int minutes) async { ... }
Future<int> readTargetUsage() async { ... }
Future<bool> isUnlockedToday() async { ... }
Future<void> markUnlockedToday() async { ... }
```

---

## 8. Implementation Sequence

Dependencies flow downward. Complete each task before starting the next unless marked **[parallel]**.

### Task 1: Schema migration and new DB classes

**Files:**
- Modify: `lib/user/config.dart` — bump `version` from `1` to `2`
- Modify: `lib/db/db_file.dart` — wire `onUpgrade` to run new `CREATE TABLE` statements
- Create: `lib/db/db_blocked_app.dart`
- Create: `lib/db/db_unlock_condition.dart`
- Create: `lib/db/db_block_session.dart`
- Create: `lib/db/db_usage_log.dart`

- [ ] **Step 1.1:** Bump `Config.version` to `2` in `lib/user/config.dart`
```dart
class Config {
  static const int version = 2;
  static String locale = 'ru';
}
```

- [ ] **Step 1.2:** Add `onUpgrade` handler in `lib/db/db_file.dart` (in `initDB` call site — the call is in `DbAchievement` and `main.dart`; the cleanest approach is to add a top-level `onUpgrade` function alongside the existing `onCreate` function in each DB class)

The existing `DbFile.initDB` accepts an `onUpgrade` callback. Create a unified upgrade runner:

```dart
// In lib/db/db_file.dart, add a static helper:
static Future<void> runUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await DbBlockedApp.db.createTable(db);
    await DbUnlockCondition.db.createTable(db);
    await DbBlockSession.db.createTable(db);
    await DbUsageLog.db.createTable(db);
  }
}
```

- [ ] **Step 1.3:** Create `lib/db/db_blocked_app.dart`
```dart
import 'package:sqflite/sqflite.dart';
import 'db_file.dart';
import 'package:achievement/data/model/blocked_app_model.dart';

class DbBlockedApp {
  DbBlockedApp._();
  static final DbBlockedApp db = DbBlockedApp._();

  final String _table = 'BlockedAppDB';

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'package_name TEXT NOT NULL UNIQUE, '
      'app_name TEXT NOT NULL, '
      'added_date INTEGER NOT NULL)',
    );
  }

  Future<List<BlockedAppModel>> getAll() async {
    final rows = await DbFile.db.query(_table);
    return rows.map(BlockedAppModel.fromJson).toList();
  }

  Future<void> insert(BlockedAppModel model) async {
    await DbFile.db.insert(_table, model.toJson()..remove('id'));
  }

  Future<void> delete(String packageName) async {
    await DbFile.db.delete(_table,
        where: 'package_name = ?', whereArgs: [packageName]);
  }
}
```

- [ ] **Step 1.4:** Create `lib/db/db_unlock_condition.dart`
```dart
import 'package:sqflite/sqflite.dart';
import 'db_file.dart';
import 'package:achievement/data/model/unlock_condition_model.dart';

class DbUnlockCondition {
  DbUnlockCondition._();
  static final DbUnlockCondition db = DbUnlockCondition._();

  final String _table = 'UnlockConditionDB';

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'condition_type INTEGER NOT NULL DEFAULT 0, '
      'target_package TEXT NOT NULL, '
      'target_app_name TEXT NOT NULL, '
      'threshold_mins INTEGER NOT NULL DEFAULT 60, '
      'is_active INTEGER NOT NULL DEFAULT 1)',
    );
  }

  Future<UnlockConditionModel?> getActive() async {
    final rows = await DbFile.db.query(_table,
        where: 'is_active = ?', whereArgs: [1], limit: 1);
    if (rows.isEmpty) return null;
    return UnlockConditionModel.fromJson(rows.first);
  }

  Future<void> upsert(UnlockConditionModel model) async {
    // Deactivate existing, insert new
    await DbFile.db.update(_table, {'is_active': 0});
    await DbFile.db.insert(_table, model.toJson()..remove('id'));
  }
}
```

- [ ] **Step 1.5:** Create `lib/db/db_block_session.dart`
```dart
import 'package:sqflite/sqflite.dart';
import 'db_file.dart';

class DbBlockSession {
  DbBlockSession._();
  static final DbBlockSession db = DbBlockSession._();

  final String _table = 'BlockSessionDB';

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'session_date TEXT NOT NULL UNIQUE, '
      'unlocked INTEGER NOT NULL DEFAULT 0, '
      'unlock_time INTEGER)',
    );
  }

  Future<bool> isUnlockedToday() async {
    final today = _today();
    final rows = await DbFile.db.query(_table,
        where: 'session_date = ?', whereArgs: [today]);
    if (rows.isEmpty) return false;
    return (rows.first['unlocked'] as int) == 1;
  }

  Future<void> markUnlocked() async {
    final today = _today();
    final now = DateTime.now().millisecondsSinceEpoch;
    await DbFile.db.update(
      _table,
      {'unlocked': 1, 'unlock_time': now},
      where: 'session_date = ?',
      whereArgs: [today],
    );
    // Insert if no row yet for today
    final rows = await DbFile.db.query(_table,
        where: 'session_date = ?', whereArgs: [today]);
    if (rows.isEmpty) {
      await DbFile.db.insert(_table, {
        'session_date': today,
        'unlocked': 1,
        'unlock_time': now,
      });
    }
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 1.6:** Create `lib/db/db_usage_log.dart`
```dart
import 'package:sqflite/sqflite.dart';
import 'db_file.dart';

class DbUsageLog {
  DbUsageLog._();
  static final DbUsageLog db = DbUsageLog._();

  final String _table = 'UsageLogDB';

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'package_name TEXT NOT NULL, '
      'log_date TEXT NOT NULL, '
      'minutes INTEGER NOT NULL, '
      'recorded_at INTEGER NOT NULL)',
    );
  }

  Future<void> insertSnapshot({
    required String packageName,
    required String logDate,
    required int minutes,
  }) async {
    await DbFile.db.insert(_table, {
      'package_name': packageName,
      'log_date': logDate,
      'minutes': minutes,
      'recorded_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
```

- [ ] **Step 1.7:** Verify `flutter analyze` passes. Commit:
```bash
git add lib/user/config.dart lib/db/db_file.dart lib/db/db_blocked_app.dart \
        lib/db/db_unlock_condition.dart lib/db/db_block_session.dart lib/db/db_usage_log.dart
git commit -m "feat: add SQLite tables for app blocking (schema v2)"
```

---

### Task 2: New data models

**Files:**
- Create: `lib/data/model/blocked_app_model.dart`
- Create: `lib/data/model/unlock_condition_model.dart`

- [ ] **Step 2.1:** Create `lib/data/model/blocked_app_model.dart`
```dart
class BlockedAppModel {
  final int id;
  final String packageName;
  final String appName;
  final DateTime addedDate;

  const BlockedAppModel({
    required this.id,
    required this.packageName,
    required this.appName,
    required this.addedDate,
  });

  factory BlockedAppModel.fromJson(Map<String, dynamic> map) => BlockedAppModel(
        id: map['id'] as int,
        packageName: map['package_name'] as String,
        appName: map['app_name'] as String,
        addedDate: DateTime.fromMillisecondsSinceEpoch(map['added_date'] as int),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'package_name': packageName,
        'app_name': appName,
        'added_date': addedDate.millisecondsSinceEpoch,
      };
}
```

- [ ] **Step 2.2:** Create `lib/data/model/unlock_condition_model.dart` (full sealed class hierarchy as shown in Section 7)

- [ ] **Step 2.3:** Run `flutter analyze`, fix any issues. Commit:
```bash
git add lib/data/model/blocked_app_model.dart lib/data/model/unlock_condition_model.dart
git commit -m "feat: add BlockedAppModel and UnlockConditionModel"
```

---

### Task 3: Extend `BlockSyncService`

**Files:**
- Modify: `lib/core/services/block_sync_service.dart`

- [ ] **Step 3.1:** Add new keys and methods as listed in Section 7 (`writeUnlockConditionType`, `writeTargetPackage`, `writeTargetUsage`, `readTargetUsage`, `isUnlockedToday`, `markUnlockedToday`).

- [ ] **Step 3.2:** Run `flutter analyze`. Commit:
```bash
git add lib/core/services/block_sync_service.dart
git commit -m "feat: extend BlockSyncService with condition and unlock-day keys"
```

---

### Task 4: New `BlocBlockingConfig` BLOC

**Files:**
- Create: `lib/bloc/bloc_blocking_config.dart`

- [ ] **Step 4.1:** Implement `BlocBlockingConfig` with `BlockingConfigLoading`, `BlockingConfigLoaded`, `BlockingConfigError` states and `addBlockedApp`, `removeBlockedApp`, `setUnlockCondition`, `checkSessionUnlocked`, `markSessionUnlocked` methods. Wire `DbBlockedApp`, `DbUnlockCondition`, `DbBlockSession`, and `BlockSyncService`.

- [ ] **Step 4.2:** Run `flutter analyze`. Commit:
```bash
git add lib/bloc/bloc_blocking_config.dart
git commit -m "feat: add BlocBlockingConfig for blocked apps and unlock conditions"
```

---

### Task 5: New `BlocUnlockProgress` BLOC

**Files:**
- Create: `lib/bloc/bloc_unlock_progress.dart`

- [ ] **Step 5.1:** Implement `BlocUnlockProgress` with `UnlockProgressLoading`, `UnlockProgressTracking` states. `refresh` event reads `BlockSyncService.readTargetUsage()`, `readThreshold()`, and `isUnlockedToday()`. If unlocked, calls `DbBlockSession.db.markUnlocked()`.

- [ ] **Step 5.2:** Run `flutter analyze`. Commit:
```bash
git add lib/bloc/bloc_unlock_progress.dart
git commit -m "feat: add BlocUnlockProgress for blocker page real-time polling"
```

---

### Task 6: Update `AppUsageService` to track target app

**Files:**
- Modify: `lib/core/services/app_usage_service.dart`

- [ ] **Step 6.1:** In `fetchTodayUsage()`, after reading `usageMap`, read the active condition's `targetPackage` from SharedPreferences (via `BlockSyncService.readTargetPackage()`). Write the target app's minutes via `BlockSyncService.writeTargetUsage(minutes)`. Keep the `achievement_usage_minutes` write for backwards compatibility with the existing `BlocAppUsage` usage display.

- [ ] **Step 6.2:** Update `background_watch_service.dart` to call `fetchTodayUsage()` (which already handles the sync). No structural change needed, but verify the `callbackDispatcher` path still compiles.

- [ ] **Step 6.3:** Run `flutter analyze`. Commit:
```bash
git add lib/core/services/app_usage_service.dart lib/core/services/background_watch_service.dart
git commit -m "feat: track target app foreground time in AppUsageService"
```

---

### Task 7: Update Android native layer

**Files:**
- Modify: `android/app/src/main/kotlin/com/ugolkov/achievement/BlockAccessibilityService.kt`
- Modify: `android/app/src/main/kotlin/com/ugolkov/achievement/MainActivity.kt`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 7.1:** Add `QUERY_ALL_PACKAGES` permission to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"
    tools:ignore="QueryAllPackagesPermission" />
```

- [ ] **Step 7.2:** Replace `achievementUsageMetThreshold()` in `BlockAccessibilityService.kt` with `unlockConditionMet()` and `checkTimeInAppCondition()` as shown in Section 3. Remove the old method entirely.

- [ ] **Step 7.3:** Add `getUnlockStatus` method to `MainActivity.kt`'s `when (call.method)` block as shown in Section 3.

- [ ] **Step 7.4:** Build and run on Android emulator/device:
```bash
flutter run
```
Verify: open a blocked app → BlockerPage appears. Verify: spend required minutes in target app → blocked app opens freely.

- [ ] **Step 7.5:** Commit:
```bash
git add android/app/src/main/AndroidManifest.xml \
        android/app/src/main/kotlin/com/ugolkov/achievement/BlockAccessibilityService.kt \
        android/app/src/main/kotlin/com/ugolkov/achievement/MainActivity.kt
git commit -m "feat: update native layer — unlockConditionMet + QUERY_ALL_PACKAGES"
```

---

### Task 8: `AppPickerPage` UI [parallel with Task 9]

**Files:**
- Create: `lib/ui/app_picker_page/app_picker_page.dart`
- Modify: `lib/core/page_routes.dart` — add `routeAppPickerPage`
- Modify: `lib/main.dart` — register route

- [ ] **Step 8.1:** Add route constant:
```dart
const String routeAppPickerPage = '/app_picker';
```

- [ ] **Step 8.2:** Register in `main.dart` routes map:
```dart
routeAppPickerPage: (context) => const AppPickerPage(),
```

- [ ] **Step 8.3:** Implement `AppPickerPage`:
  - `BlocProvider<BlocBlockingConfig>` wraps the body
  - `StreamBuilder` on `BlocBlockingConfig.outState`
  - Top: `TextField` search bar
  - Body: `ListView.builder` of all installed apps from `InstalledApps.getInstalledApps(true, true)`, filtered by search text, sorted alphabetically
  - Each row: `ListTile` with app icon, name, and `IconButton(Icons.block / Icons.block_outlined)` toggle
  - Toggle calls `BlocBlockingConfig.addBlockedApp` or `removeBlockedApp`
  - Filter out `com.ugolkov.achievement` from list

- [ ] **Step 8.4:** Run `flutter analyze`. Test on device. Commit:
```bash
git add lib/ui/app_picker_page/app_picker_page.dart lib/core/page_routes.dart lib/main.dart
git commit -m "feat: add AppPickerPage for selecting apps to block"
```

---

### Task 9: `ConditionConfigPage` UI [parallel with Task 8]

**Files:**
- Create: `lib/ui/condition_config_page/condition_config_page.dart`
- Modify: `lib/core/page_routes.dart` — add `routeConditionConfigPage`
- Modify: `lib/main.dart` — register route

- [ ] **Step 9.1:** Add route and register in `main.dart` (same pattern as Task 8).

- [ ] **Step 9.2:** Implement `ConditionConfigPage`:
  - Shows condition type as `RadioListTile` group (only `timeInApp` enabled; future types are disabled with "(Coming soon)" subtitle)
  - Target app selector: `ListTile` with current target app name/icon; tap opens a bottom sheet with `InstalledApps` list (exclude already-blocked apps since using a blocked app as the target creates a deadlock)
  - Threshold: `Slider(min: 5, max: 180, divisions: 35)` with label `'${value.round()} min'`
  - Save button: validates that target app is selected, calls `BlocBlockingConfig.setUnlockCondition(TimeInAppCondition(...))`

- [ ] **Step 9.3:** Run `flutter analyze`. Test on device. Commit:
```bash
git add lib/ui/condition_config_page/condition_config_page.dart lib/core/page_routes.dart lib/main.dart
git commit -m "feat: add ConditionConfigPage for unlock rule configuration"
```

---

### Task 10: Update `AppUsagePage` navigation

**Files:**
- Modify: `lib/ui/app_usage_page/app_usage_page.dart`

- [ ] **Step 10.1:** Add two `IconButton`s to the page's `AppBar` (or add action buttons inside the body above the list):
  - "Blocked Apps" → `Navigator.pushNamed(context, routeAppPickerPage)`
  - "Unlock Rule" → `Navigator.pushNamed(context, routeConditionConfigPage)`

- [ ] **Step 10.2:** Remove `_ThresholdSelector` widget from this page (it is now in `ConditionConfigPage`).

- [ ] **Step 10.3:** Run `flutter analyze`. Commit:
```bash
git add lib/ui/app_usage_page/app_usage_page.dart
git commit -m "feat: add navigation to AppPickerPage and ConditionConfigPage from AppUsagePage"
```

---

### Task 11: `UnlockSuccessPage` + update `BlockerPage`

**Files:**
- Create: `lib/ui/unlock_success_page/unlock_success_page.dart`
- Modify: `lib/ui/blocker_page/blocker_page.dart`
- Modify: `lib/core/page_routes.dart` — add `routeUnlockSuccessPage`
- Modify: `lib/main.dart` — register route

- [ ] **Step 11.1:** Implement `UnlockSuccessPage`:
```dart
class UnlockSuccessPage extends StatelessWidget {
  const UnlockSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'Приложения разблокированы!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Заблокированные приложения доступны до полуночи.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Продолжить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 11.2:** Update `BlockerPage` to use `BlocUnlockProgress`:
  - Remove direct `BlockSyncService` calls
  - Wrap body with `BlocProvider<BlocUnlockProgress>`
  - `StreamBuilder` on `BlocUnlockProgress.outState`
  - Add `Timer.periodic(Duration(minutes: 1), (_) => _bloc.inEvent.add(UnlockProgressEvent.refresh))`
  - When `UnlockProgressTracking.unlocked == true`: navigate with replace to `/unlock_success`

- [ ] **Step 11.3:** Run `flutter analyze`. Test on device: trigger block → BlockerPage → satisfy condition → UnlockSuccessPage. Commit:
```bash
git add lib/ui/unlock_success_page/unlock_success_page.dart \
        lib/ui/blocker_page/blocker_page.dart \
        lib/core/page_routes.dart lib/main.dart
git commit -m "feat: add UnlockSuccessPage and wire BlocUnlockProgress to BlockerPage"
```

---

### Task 12: iOS guard

**Files:**
- Modify: `lib/ui/app_usage_page/app_usage_page.dart` (or the tab that hosts it)

- [ ] **Step 12.1:** In `AppUsagePage.build()` (or in `_AppUsageBodyState`), add a top-level `Platform.isIOS` check. If iOS, return a centered message widget:
```dart
if (Platform.isIOS) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Блокировка приложений доступна только на Android.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
```

- [ ] **Step 12.2:** Commit:
```bash
git add lib/ui/app_usage_page/app_usage_page.dart
git commit -m "feat: show iOS unavailability message on App Usage tab"
```

---

### Task 13: End-to-end smoke test

- [ ] **Step 13.1:** On a physical Android device (or emulator with accessibility support):
  1. Grant Usage Access permission.
  2. Enable Achievement Accessibility Service in Android Settings.
  3. Navigate to App Usage tab → Blocked Apps → block one app (e.g. YouTube).
  4. Navigate to App Usage tab → Unlock Rule → select YouTube (or another target app), set threshold to 5 minutes.
  5. Open YouTube → verify BlockerPage appears.
  6. Return to Achievement → spend 5 minutes in Achievement (or manually advance `target_usage_minutes` via dev tools / temporarily lower threshold to 1 minute).
  7. Return to BlockerPage → verify it transitions to UnlockSuccessPage.
  8. Open YouTube → verify it opens without blocking.

- [ ] **Step 13.2:** Verify next-day reset behavior: change device date to tomorrow → open blocked app → verify BlockerPage appears again.

---

## 9. Risks and Open Questions

### Android Version Compatibility

| Risk | Detail | Mitigation |
|---|---|---|
| `UsageStats` API unreliable on some OEM ROMs | Huawei, Xiaomi, and some Samsung devices restrict background processes and UsageStatsManager. The `app_usage` plugin may return stale or empty data. | Show a banner if `fetchTodayUsage()` returns empty after permissions are granted. Log to `UsageLogDB` when data is received vs. empty. |
| `QUERY_ALL_PACKAGES` review on Google Play | Google Play requires justification for this permission. | Acceptable for a self-distributed / side-loaded app. If publishing to Play, use targeted `<queries>` entries instead and accept that some apps may not appear. |
| `AccessibilityService` killed by battery optimizer | Aggressive battery optimizers (Xiaomi, Oppo) kill accessibility services. Blocking becomes unreliable. | Add a banner instructing users to whitelist Achievement in battery settings. Mirror the pattern of apps like StayFocused (task reference). |
| Android 14+ restricts accessibility service configuration | Some APIs behave differently on API 34+. The `windows` API for `getForegroundAppPackage()` may require `canRetrieveWindowContent = true` in the accessibility config XML. | Verify `accessibility_service_config.xml` includes `canRetrieveWindowContent="true"` and `accessibilityEventTypes` covers both event types used. |

### UX Edge Cases

| Scenario | Handling |
|---|---|
| User sets the target app as a blocked app | `ConditionConfigPage` should exclude already-blocked apps from the target picker. If target is added to block list later, detect this conflict in `BlocBlockingConfig` and show a warning. |
| User opens Achievement while it is in the block list | Achievement's own package (`com.ugolkov.achievement`) is always excluded from the block list in `AppPickerPage` and in `isInBlockList()` in Kotlin. |
| Threshold set to 0 | `ConditionConfigPage` slider minimum is 5 minutes. In `unlockConditionMet()` Kotlin side, if `threshold == 0`, return `true` (treat as no condition). |
| Device reboot | `RECEIVE_BOOT_COMPLETED` is already in the manifest. Workmanager re-registers periodic tasks after boot. SharedPreferences persists across reboots — `block_list` and `unlocked_day` remain valid. |
| Blocked app launched at midnight | If `unlocked_day` is yesterday's date, the Kotlin service correctly returns `false` from `unlockConditionMet()` (the day check fails). Blocking resumes at midnight with no Flutter involvement. |
| Multiple blocked apps → user opens one after another | The 3-second cooldown in `BlockAccessibilityService` prevents rapid re-triggering for the same package. Different packages each trigger independently. |
| User disables Accessibility Service mid-session | Blocking stops immediately. The `_AccessibilityBanner` in `AppUsagePage` re-checks every time the page is mounted; it will show the re-enable prompt next time the user opens the tab. |

### Battery and Performance

- The 1-minute `Timer.periodic` in `BlockerPage` only runs while `BlockerPage` is visible — it is cancelled in `dispose()`. No persistent background drain from this timer.
- The Workmanager 15-minute periodic task is already in place. It syncs block list and usage — no additional background work needed for v1.
- `InstalledApps.getInstalledApps()` can be slow (~1-3 seconds on devices with many apps). Cache the result in `AppPickerPage`'s state for the duration of the page visit; do not re-fetch on every rebuild.
- `UsageLogDB` appends a row every time `fetchTodayUsage()` runs (up to ~100 rows/day). Add a cleanup query that deletes rows older than 30 days, run once per day on app startup.

### Open Questions

1. **Notification on unlock:** Should the app fire a local notification when the condition is met (so the user knows they can now open their blocked apps even if Achievement is in background)? Not in scope for v1 but worth noting for v2.
2. **Multiple unlock conditions:** The current design supports one active condition. Should future versions support "ALL of [condition list]" or "ANY of [condition list]"? Reserve the `is_active` column for this — it can be repurposed as a group ID.
3. **Block list backup:** The block list is in SQLite but SharedPreferences sync is the source of truth for the native layer. If the DB and SharedPreferences get out of sync (e.g. app killed during write), the sync in `BlocBlockingConfig._init()` (mirrors `BlocAppUsage._init()`) will re-sync from DB on next app open.
4. **Foreground time tracking accuracy:** The `app_usage` plugin uses Android's `UsageStatsManager`, which reports usage in whole minutes. A user who opens a target app for 59 seconds does not get credit. This is acceptable for v1 (matches StayFocused behavior) but should be documented in the UI.