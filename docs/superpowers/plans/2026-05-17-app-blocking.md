# App Blocking Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Block selected apps (e.g. YouTube) until the user has spent a configurable amount of time in the Achievement app today, enforced via an Android Accessibility Service that shows a Flutter blocker screen.

**Architecture:** A Kotlin `BlockAccessibilityService` detects foreground app changes via `TYPE_WINDOW_STATE_CHANGED` events. It reads the block list, threshold, and achievement usage from `FlutterSharedPreferences` (written by Dart via `shared_preferences`). When a blocked app is opened before the threshold is met, it launches `MainActivity` with an intent extra, which Flutter routes to `BlockerPage`.

**Tech Stack:** Flutter/Dart, `shared_preferences ^2.x`, Kotlin AccessibilityService, Android SharedPreferences, MethodChannel, `flutter_test`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `pubspec.yaml` | Modify | Add `shared_preferences` dependency |
| `lib/core/services/block_sync_service.dart` | Create | Write/read block data to SharedPreferences |
| `lib/core/services/app_usage_service.dart` | Modify | Write achievement usage to SP after fetch |
| `lib/bloc/bloc_app_usage.dart` | Modify | Sync blocklist+threshold to SP; expose threshold in state |
| `lib/ui/blocker_page/blocker_page.dart` | Create | Blocker screen with progress bar |
| `lib/main.dart` | Modify | GlobalKey<NavigatorState>, /blocker route, MethodChannel setup |
| `android/app/src/main/kotlin/com/example/achievement/MainActivity.kt` | Modify | MethodChannel: intent extras, accessibility check, open settings |
| `android/app/src/main/res/xml/accessibility_service_config.xml` | Create | Accessibility service event config |
| `android/app/src/main/kotlin/com/example/achievement/BlockAccessibilityService.kt` | Create | Detects blocked apps, launches blocker |
| `android/app/src/main/AndroidManifest.xml` | Modify | Register BlockAccessibilityService |
| `lib/ui/app_usage_page/app_usage_page.dart` | Modify | Threshold dropdown, accessibility status banner |
| `test/core/services/block_sync_service_test.dart` | Create | Unit tests for BlockSyncService |
| `test/ui/blocker_page_test.dart` | Create | Widget tests for BlockerPage |

---

## Task 1: Add shared_preferences dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependency**

In `pubspec.yaml`, under `dependencies:`, add after `app_usage: ^4.1.0`:
```yaml
  shared_preferences: ^2.3.0
```

- [ ] **Step 2: Install**

```bash
flutter pub get
```

Expected: resolves without conflicts.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: add shared_preferences dependency"
```

---

## Task 2: Create BlockSyncService

**Files:**
- Create: `lib/core/services/block_sync_service.dart`
- Create: `test/core/services/block_sync_service_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/services/block_sync_service_test.dart`:
```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:achievement/core/services/block_sync_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('writeBlockList stores JSON-encoded list', () async {
    final svc = BlockSyncService();
    await svc.writeBlockList(['com.google.android.youtube', 'com.facebook.katana']);
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('block_list');
    expect(jsonDecode(stored!), ['com.google.android.youtube', 'com.facebook.katana']);
  });

  test('writeThreshold stores int', () async {
    final svc = BlockSyncService();
    await svc.writeThreshold(30);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('threshold_minutes'), 30);
  });

  test('readThreshold returns default 60 when unset', () async {
    final svc = BlockSyncService();
    expect(await svc.readThreshold(), 60);
  });

  test('writeAchievementUsage and readAchievementUsage round-trip', () async {
    final svc = BlockSyncService();
    await svc.writeAchievementUsage(45);
    expect(await svc.readAchievementUsage(), 45);
  });
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
flutter test test/core/services/block_sync_service_test.dart
```

Expected: FAIL — `block_sync_service.dart` does not exist.

- [ ] **Step 3: Implement BlockSyncService**

Create `lib/core/services/block_sync_service.dart`:
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BlockSyncService {
  static const _blockListKey = 'block_list';
  static const _thresholdKey = 'threshold_minutes';
  static const _achievementUsageKey = 'achievement_usage_minutes';

  Future<void> writeBlockList(List<String> packages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_blockListKey, jsonEncode(packages));
  }

  Future<void> writeThreshold(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_thresholdKey, minutes);
  }

  Future<void> writeAchievementUsage(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_achievementUsageKey, minutes);
  }

  Future<int> readThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_thresholdKey) ?? 60;
  }

  Future<int> readAchievementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_achievementUsageKey) ?? 0;
  }
}
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
flutter test test/core/services/block_sync_service_test.dart
```

Expected: All 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/block_sync_service.dart test/core/services/block_sync_service_test.dart
git commit -m "feat: add BlockSyncService for SharedPreferences sync"
```

---

## Task 3: Write achievement usage to SharedPreferences

**Files:**
- Modify: `lib/core/services/app_usage_service.dart`

- [ ] **Step 1: Add import and write call to `fetchTodayUsage`**

In `lib/core/services/app_usage_service.dart`, add import at top:
```dart
import 'package:achievement/core/services/block_sync_service.dart';
```

Inside `fetchTodayUsage()`, add after building `usageMap` (after the `if (usageMap.isEmpty) return [];` check) and before fetching installed apps — specifically, extract and write achievement usage. Add this block before the `final installedApps = ...` line:

```dart
const kAchievementPackage = 'com.ugolkov.achievement';
final achievementMinutes = usageMap[kAchievementPackage] ?? 0;
await BlockSyncService().writeAchievementUsage(achievementMinutes);
```

The modified section of `fetchTodayUsage()` (lines 56–66) becomes:
```dart
      if (usageMap.isEmpty) return [];

      const kAchievementPackage = 'com.ugolkov.achievement';
      final achievementMinutes = usageMap[kAchievementPackage] ?? 0;
      await BlockSyncService().writeAchievementUsage(achievementMinutes);

      final installedApps = await InstalledApps.getInstalledApps(false, true);
```

- [ ] **Step 2: Analyze for errors**

```bash
flutter analyze lib/core/services/app_usage_service.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/core/services/app_usage_service.dart
git commit -m "feat: write achievement usage to SharedPreferences on fetch"
```

---

## Task 4: Update BlocAppUsage — threshold and blocklist sync

**Files:**
- Modify: `lib/bloc/bloc_app_usage.dart`

`AppUsageStateLoaded` needs `thresholdMinutes`. `BlocAppUsage` needs to load threshold on init, sync blocklist on toggle, and expose `setThreshold`.

- [ ] **Step 1: Update `AppUsageStateLoaded` to include threshold**

In `lib/bloc/bloc_app_usage.dart`, replace:
```dart
class AppUsageStateLoaded extends AppUsageState {
  final List<AppUsageModel> apps;
  final Set<String> watchedPackages;
  AppUsageStateLoaded(this.apps, this.watchedPackages);
}
```
with:
```dart
class AppUsageStateLoaded extends AppUsageState {
  final List<AppUsageModel> apps;
  final Set<String> watchedPackages;
  final int thresholdMinutes;
  AppUsageStateLoaded(this.apps, this.watchedPackages, this.thresholdMinutes);
}
```

- [ ] **Step 2: Add threshold field, update `_init`, update `_handleLoad`, update `toggleWatch`, add `setThreshold`**

Replace the full `BlocAppUsage` class body in `lib/bloc/bloc_app_usage.dart` with:
```dart
import 'package:achievement/core/services/block_sync_service.dart';
```
Add this import at the top of the file.

Then replace the class:
```dart
class BlocAppUsage extends BlocBase {
  final StreamController<AppUsageState> _stateController =
      StreamController<AppUsageState>();
  final StreamController<AppUsageEvent> _eventController =
      StreamController<AppUsageEvent>();

  Sink<AppUsageEvent> get inEvent => _eventController.sink;
  Stream<AppUsageState> get outState => _stateController.stream;

  Stream<AppUsageEvent> get _outEvent => _eventController.stream;
  Sink<AppUsageState> get _inState => _stateController.sink;

  Map<String, String> _watchlist = {};
  List<AppUsageModel> _lastApps = [];
  int _thresholdMinutes = 60;

  BlocAppUsage() {
    _outEvent.listen(_handleEvent);
    _init();
  }

  Future<void> _init() async {
    _watchlist = await AppUsageService().loadWatchlist();
    _thresholdMinutes = await BlockSyncService().readThreshold();
    _eventController.add(AppUsageEvent.load);
  }

  @override
  void dispose() {
    _eventController.close();
    _stateController.close();
  }

  void _handleEvent(AppUsageEvent event) {
    switch (event) {
      case AppUsageEvent.load:
      case AppUsageEvent.refresh:
        _handleLoad();
    }
  }

  Future<void> _handleLoad() async {
    _inState.add(AppUsageStateLoading());
    try {
      final service = AppUsageService();
      final hasPermission = await service.hasPermission();
      if (!hasPermission) {
        _inState.add(AppUsageStatePermissionDenied());
        return;
      }
      final apps = await service.fetchTodayUsage();
      _lastApps = apps;
      _inState.add(AppUsageStateLoaded(apps, _watchlist.keys.toSet(), _thresholdMinutes));
    } catch (e) {
      _inState.add(AppUsageStateError(e.toString()));
    }
  }

  Future<void> toggleWatch(String packageName, String appName) async {
    if (_watchlist.containsKey(packageName)) {
      _watchlist.remove(packageName);
    } else {
      _watchlist[packageName] = appName;
    }
    await AppUsageService().saveWatchlist(_watchlist);
    await BlockSyncService().writeBlockList(_watchlist.keys.toList());
    _inState.add(AppUsageStateLoaded(_lastApps, _watchlist.keys.toSet(), _thresholdMinutes));
  }

  Future<void> setThreshold(int minutes) async {
    _thresholdMinutes = minutes;
    await BlockSyncService().writeThreshold(minutes);
    _inState.add(AppUsageStateLoaded(_lastApps, _watchlist.keys.toSet(), _thresholdMinutes));
  }

  Future<List<AppUsageModel>> checkWatchedUnderThreshold() async {
    if (_watchlist.isEmpty) return [];
    final apps = await AppUsageService().fetchTodayUsage();
    return apps
        .where((a) =>
            _watchlist.containsKey(a.packageName) &&
            a.usageMinutes < 1440)
        .toList();
  }
}
```

- [ ] **Step 3: Analyze**

```bash
flutter analyze lib/bloc/bloc_app_usage.dart
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/bloc/bloc_app_usage.dart
git commit -m "feat: sync blocklist and threshold to SharedPreferences in BlocAppUsage"
```

---

## Task 5: Create BlockerPage

**Files:**
- Create: `lib/ui/blocker_page/blocker_page.dart`
- Create: `test/ui/blocker_page_test.dart`

- [ ] **Step 1: Write failing widget test**

Create `test/ui/blocker_page_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:achievement/ui/blocker_page/blocker_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'threshold_minutes': 60,
      'achievement_usage_minutes': 20,
    });
  });

  testWidgets('shows lock icon and blocked package name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const BlockerPage(),
        onGenerateRoute: (settings) {
          if (settings.name == '/blocker') {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const BlockerPage(),
            );
          }
          return null;
        },
        initialRoute: '/blocker',
        routes: {},
      ),
    );
    // Provide route argument by wrapping in Navigator
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            settings: RouteSettings(
              name: '/blocker',
              arguments: 'com.google.android.youtube',
            ),
            builder: (_) => const BlockerPage(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.text('com.google.android.youtube'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('На главную'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to confirm it fails**

```bash
flutter test test/ui/blocker_page_test.dart
```

Expected: FAIL — `blocker_page.dart` not found.

- [ ] **Step 3: Create BlockerPage**

Create `lib/ui/blocker_page/blocker_page.dart`:
```dart
import 'package:achievement/core/services/block_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlockerPage extends StatefulWidget {
  const BlockerPage({super.key});

  @override
  State<BlockerPage> createState() => _BlockerPageState();
}

class _BlockerPageState extends State<BlockerPage> {
  int _usageMinutes = 0;
  int _thresholdMinutes = 60;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final sync = BlockSyncService();
    final usage = await sync.readAchievementUsage();
    final threshold = await sync.readThreshold();
    if (!mounted) return;
    setState(() {
      _usageMinutes = usage;
      _thresholdMinutes = threshold;
    });
  }

  @override
  Widget build(BuildContext context) {
    final blockedPackage =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';
    final progress = _thresholdMinutes > 0
        ? (_usageMinutes / _thresholdMinutes).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (_thresholdMinutes - _usageMinutes).clamp(0, _thresholdMinutes);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.redAccent),
              const SizedBox(height: 24),
              Text(
                'Приложение заблокировано',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                blockedPackage,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 12),
              Text('$_usageMinutes / $_thresholdMinutes мин в Achievement'),
              const SizedBox(height: 4),
              Text(
                'Осталось ещё $remaining мин',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              const Text(
                'Сначала поработай над своими целями!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('На главную'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/ui/blocker_page_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/blocker_page/blocker_page.dart test/ui/blocker_page_test.dart
git commit -m "feat: add BlockerPage with progress bar and motivational message"
```

---

## Task 6: Update main.dart — navigatorKey, /blocker route, MethodChannel

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Add navigatorKey, MethodChannel setup, and /blocker route**

Replace the full content of `lib/main.dart` with:
```dart
import 'package:achievement/core/data_application.dart';
import 'package:achievement/core/firebase_controller.dart';
import 'package:achievement/core/notification/local_notification.dart';
import 'package:achievement/core/override_theme_data.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/core/services/background_watch_service.dart';
import 'package:achievement/ui/about_page/about_page.dart';
import 'package:achievement/ui/achievements_page/achievements_page.dart';
import 'package:achievement/ui/blocker_page/blocker_page.dart';
import 'package:achievement/ui/edit_achievement_page/edit_achievement_page.dart';
import 'package:achievement/ui/settings_page/settings_page.dart';
import 'package:achievement/ui/view_achievement_page/view_achievement_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:achievement/generated/l10n.dart';
import 'package:achievement/core/utils.dart' as utils;
import 'package:workmanager/workmanager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const _blockerChannel = MethodChannel('com.ugolkov.achievement/blocker');

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  void startApp() async {
    var docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;

    await FirebaseController.init();

    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      kWatchTaskUniqueName,
      kWatchTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );

    runApp(const MyApp());

    // Check if app was launched from the accessibility service blocker intent
    final pendingPackage = await _blockerChannel
        .invokeMethod<String>('getPendingBlockedPackage');
    if (pendingPackage != null && pendingPackage.isNotEmpty) {
      navigatorKey.currentState
          ?.pushNamed('/blocker', arguments: pendingPackage);
    }

    // Listen for blocker events while app is running
    _blockerChannel.setMethodCallHandler((call) async {
      if (call.method == 'showBlocker') {
        navigatorKey.currentState
            ?.pushNamed('/blocker', arguments: call.arguments as String);
      }
    });
  }

  DataApplication();
  LocalNotification.init();
  startApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      locale: const Locale('ru'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'Achievement',
      initialRoute: '/',
      routes: {
        routeEditAchievementPage: (context) => EditAchievementPage(),
        routeViewAchievementPage: (context) => ViewAchievementPage(),
        routeSettingsPage: (context) => SettingsPage(),
        routeAboutPage: (context) => AboutPage(),
        '/blocker': (context) => const BlockerPage(),
      },
      navigatorObservers: <NavigatorObserver>[
        if (kReleaseMode) FirebaseController.createObserver()
      ],
      theme: buildThemeLight(),
      darkTheme: buildThemeDark(),
      home: AchievementsPage(),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/main.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: add navigatorKey, /blocker route, and MethodChannel in main.dart"
```

---

## Task 7: Update MainActivity.kt — MethodChannel bridge

**Files:**
- Modify: `android/app/src/main/kotlin/com/example/achievement/MainActivity.kt`

- [ ] **Step 1: Replace MainActivity.kt**

```kotlin
package com.ugolkov.achievement

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.ugolkov.achievement/blocker"
    private var pendingBlockedPackage: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingBlockedPackage = intent?.getStringExtra("blocked_package")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val pkg = intent.getStringExtra("blocked_package") ?: return
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, channelName).invokeMethod("showBlocker", pkg)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPendingBlockedPackage" -> {
                        result.success(pendingBlockedPackage)
                        pendingBlockedPackage = null
                    }
                    "isAccessibilityEnabled" -> {
                        val enabledServices = Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                        ) ?: ""
                        result.success(
                            enabledServices.contains("$packageName/com.ugolkov.achievement.BlockAccessibilityService")
                        )
                    }
                    "openAccessibilitySettings" -> {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

- [ ] **Step 2: Build to confirm it compiles**

```bash
flutter build apk --debug 2>&1 | tail -20
```

Expected: BUILD SUCCESSFUL (or only pre-existing warnings).

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/kotlin/com/example/achievement/MainActivity.kt
git commit -m "feat: add MethodChannel in MainActivity for blocker and accessibility"
```

---

## Task 8: Create accessibility service config XML

**Files:**
- Create: `android/app/src/main/res/xml/accessibility_service_config.xml`

- [ ] **Step 1: Create res/xml directory and config file**

```bash
mkdir -p android/app/src/main/res/xml
```

Create `android/app/src/main/res/xml/accessibility_service_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagDefault"
    android:notificationTimeout="100"
    android:canRetrieveWindowContent="false" />
```

- [ ] **Step 2: Commit**

```bash
git add android/app/src/main/res/xml/accessibility_service_config.xml
git commit -m "feat: add accessibility service config XML"
```

---

## Task 9: Create BlockAccessibilityService.kt

**Files:**
- Create: `android/app/src/main/kotlin/com/example/achievement/BlockAccessibilityService.kt`

- [ ] **Step 1: Create the service**

Create `android/app/src/main/kotlin/com/example/achievement/BlockAccessibilityService.kt`:
```kotlin
package com.ugolkov.achievement

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import org.json.JSONArray

class BlockAccessibilityService : AccessibilityService() {
    private val achievementPackage = "com.ugolkov.achievement"

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val packageName = event.packageName?.toString() ?: return
        if (packageName == achievementPackage) return
        if (!isInBlockList(packageName)) return
        if (achievementUsageMetThreshold()) return
        launchBlocker(packageName)
    }

    private fun isInBlockList(packageName: String): Boolean {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val json = prefs.getString("flutter.block_list", "[]") ?: return false
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).any { arr.getString(it) == packageName }
        } catch (_: Exception) {
            false
        }
    }

    private fun achievementUsageMetThreshold(): Boolean {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val usage = prefs.getInt("flutter.achievement_usage_minutes", 0)
        val threshold = prefs.getInt("flutter.threshold_minutes", 60)
        return usage >= threshold
    }

    private fun launchBlocker(blockedPackage: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("blocked_package", blockedPackage)
        }
        startActivity(intent)
    }

    override fun onInterrupt() {}
}
```

- [ ] **Step 2: Build to confirm compilation**

```bash
flutter build apk --debug 2>&1 | tail -20
```

Expected: BUILD SUCCESSFUL.

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/kotlin/com/example/achievement/BlockAccessibilityService.kt
git commit -m "feat: add BlockAccessibilityService for app blocking"
```

---

## Task 10: Register BlockAccessibilityService in AndroidManifest.xml

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add service declaration**

Inside `<application>`, after the closing `</activity>` tag and before the `<meta-data android:name="flutterEmbedding".../>`, add:
```xml
        <service
            android:name=".BlockAccessibilityService"
            android:exported="true"
            android:label="Achievement Blocker"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data
                android:name="android.accessibilityservice"
                android:resource="@xml/accessibility_service_config" />
        </service>
```

- [ ] **Step 2: Build to confirm**

```bash
flutter build apk --debug 2>&1 | tail -20
```

Expected: BUILD SUCCESSFUL.

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/AndroidManifest.xml
git commit -m "feat: register BlockAccessibilityService in AndroidManifest"
```

---

## Task 11: Update AppUsagePage — threshold dropdown and accessibility banner

**Files:**
- Modify: `lib/ui/app_usage_page/app_usage_page.dart`

- [ ] **Step 1: Add accessibility check state and threshold UI to `_AppUsageBodyState`**

Replace the full content of `lib/ui/app_usage_page/app_usage_page.dart` with:
```dart
import 'dart:async';

import 'package:achievement/bloc/bloc_app_usage.dart';
import 'package:achievement/bloc/bloc_provider.dart';
import 'package:achievement/data/model/app_usage_model.dart';
import 'package:achievement/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _blockerChannel = MethodChannel('com.ugolkov.achievement/blocker');

const _thresholdOptions = [15, 30, 60, 90, 120];

class AppUsagePage extends StatelessWidget {
  const AppUsagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocAppUsage>(
      bloc: BlocAppUsage(),
      child: const _AppUsageBody(),
    );
  }
}

class _AppUsageBody extends StatefulWidget {
  const _AppUsageBody();

  @override
  State<_AppUsageBody> createState() => _AppUsageBodyState();
}

class _AppUsageBodyState extends State<_AppUsageBody> {
  late BlocAppUsage _bloc;
  Timer? _watchTimer;
  bool _accessibilityEnabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<BlocAppUsage>(context);
    _watchTimer ??= Timer.periodic(const Duration(minutes: 1), _onTimerTick);
    _checkAccessibility();
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAccessibility() async {
    try {
      final enabled = await _blockerChannel
          .invokeMethod<bool>('isAccessibilityEnabled') ?? false;
      if (mounted) setState(() => _accessibilityEnabled = enabled);
    } catch (_) {}
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      await _blockerChannel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  Future<void> _onTimerTick(Timer _) async {
    _checkAccessibility();
    final underThreshold = await _bloc.checkWatchedUnderThreshold();
    if (!mounted || underThreshold.isEmpty) return;
    _showWatchAlert(underThreshold);
  }

  void _showWatchAlert(List<AppUsageModel> apps) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Наблюдаемые приложения'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: apps
                .map(
                  (a) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${a.appName}: ${_formatMinutes(a.usageMinutes)}',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUsageState>(
      stream: _bloc.outState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == null || state is AppUsageStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AppUsageStatePermissionDenied) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                S.of(context).appUsagePermissionDenied,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (state is AppUsageStateError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message, textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => _bloc.inEvent.add(AppUsageEvent.refresh),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }
        if (state is AppUsageStateLoaded) {
          return Column(
            children: [
              _AccessibilityBanner(
                enabled: _accessibilityEnabled,
                onEnable: _openAccessibilitySettings,
              ),
              _ThresholdSelector(
                value: state.thresholdMinutes,
                onChanged: _bloc.setThreshold,
              ),
              if (state.apps.isEmpty)
                Expanded(
                  child: Center(child: Text(S.of(context).appUsageEmpty)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: state.apps.length,
                    itemBuilder: (context, index) {
                      final model = state.apps[index];
                      return _AppTile(
                        model: model,
                        isWatched:
                            state.watchedPackages.contains(model.packageName),
                        onToggleWatch: () =>
                            _bloc.toggleWatch(model.packageName, model.appName),
                      );
                    },
                  ),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AccessibilityBanner extends StatelessWidget {
  final bool enabled;
  final VoidCallback onEnable;

  const _AccessibilityBanner({required this.enabled, required this.onEnable});

  @override
  Widget build(BuildContext context) {
    if (enabled) return const SizedBox.shrink();
    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      content: const Text(
        'Включи сервис специальных возможностей для блокировки приложений',
      ),
      actions: [
        TextButton(
          onPressed: onEnable,
          child: const Text('Включить'),
        ),
      ],
    );
  }
}

class _ThresholdSelector extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const _ThresholdSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final safeValue = _thresholdOptions.contains(value) ? value : 60;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Порог для разблокировки:'),
          const SizedBox(width: 12),
          DropdownButton<int>(
            value: safeValue,
            items: _thresholdOptions
                .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text('$m мин'),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final AppUsageModel model;
  final bool isWatched;
  final VoidCallback onToggleWatch;

  const _AppTile({
    required this.model,
    required this.isWatched,
    required this.onToggleWatch,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildIcon(),
      title: Text(model.appName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_formatMinutes(model.usageMinutes)),
          IconButton(
            icon: Icon(
              isWatched ? Icons.block : Icons.block_outlined,
              color: isWatched ? Colors.redAccent : null,
            ),
            tooltip: isWatched ? 'Снять блокировку' : 'Заблокировать',
            onPressed: onToggleWatch,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    final icon = model.icon;
    if (icon != null && icon.isNotEmpty) {
      return Image.memory(icon, width: 40, height: 40);
    }
    return const Icon(Icons.apps, size: 40);
  }
}

String _formatMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours > 0) return '$hours ч $mins м';
  return '$mins м';
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/ui/app_usage_page/app_usage_page.dart
```

Expected: no errors.

- [ ] **Step 3: Full project analyze**

```bash
flutter analyze
```

Expected: no errors (only pre-existing warnings allowed).

- [ ] **Step 4: Run all tests**

```bash
flutter test
```

Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/app_usage_page/app_usage_page.dart
git commit -m "feat: add threshold selector and accessibility banner to AppUsagePage"
```

---

## Manual Testing Checklist

After building a debug APK (`flutter build apk --debug`), test on a physical Android device:

- [ ] App installs and launches without crash
- [ ] AppUsagePage shows list of apps with usage times
- [ ] Accessibility banner visible → tap "Включить" → opens Android Accessibility settings
- [ ] Enable "Achievement Blocker" service in settings → banner disappears on return
- [ ] Threshold dropdown changes value and persists on re-open
- [ ] Tap block icon on an app (e.g. YouTube) → icon turns red
- [ ] Open that app on the device → BlockerPage appears immediately
- [ ] BlockerPage shows progress bar, remaining minutes, package name
- [ ] Tap "На главную" → goes to home screen
- [ ] After threshold is met, opening the app works without blocking
