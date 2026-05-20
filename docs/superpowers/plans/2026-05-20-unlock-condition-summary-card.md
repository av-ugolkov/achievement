# Unlock Condition Summary Card — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `_UnlockConditionCard` widget to `AppUsagePage` that shows the active unlock condition (target app + progress toward threshold) with three states: no condition set, in progress, and unlocked today.

**Architecture:** `_UnlockConditionCard` is a private widget inside `app_usage_page.dart` that subscribes to a `BlocUnlockProgress` instance owned by `_AppUsageBodyState`. The existing 1-minute timer in `_AppUsageBodyState` fires `UnlockProgressEvent.refresh` so the card stays current. `BlocUnlockProgress` gets a minimal extension — a `hasCondition` bool on `UnlockProgressTracking` — to distinguish "no condition configured" from "condition set with 0 progress".

**Tech Stack:** Flutter 3.41.9, Dart 3.11.5, custom stream-based BLOC pattern, `sqflite`, `shared_preferences`.

---

## File Map

| File | Change |
|---|---|
| `lib/bloc/bloc_unlock_progress.dart` | Add `hasCondition` field to `UnlockProgressTracking`; update `_handleRefresh` to set it |
| `lib/ui/app_usage_page/app_usage_page.dart` | Add `_progressBloc` field; add `_UnlockConditionCard` widget; wire timer |

---

## Task 1: Add `hasCondition` to `UnlockProgressTracking`

**Files:**
- Modify: `lib/bloc/bloc_unlock_progress.dart`

This exposes whether an active condition exists in the DB, so `_UnlockConditionCard` can show the "not configured" state without querying the DB itself.

- [ ] **Step 1.1 — Add `hasCondition` field to `UnlockProgressTracking`**

Replace the class definition (lines 13–25 in `bloc_unlock_progress.dart`):

```dart
class UnlockProgressTracking extends UnlockProgressState {
  final int usageMinutes;
  final int thresholdMinutes;
  final String targetAppName;
  final bool unlocked;
  final bool hasCondition;

  UnlockProgressTracking({
    required this.usageMinutes,
    required this.thresholdMinutes,
    required this.targetAppName,
    required this.unlocked,
    this.hasCondition = true,
  });
}
```

- [ ] **Step 1.2 — Update `_handleRefresh` to set `hasCondition`**

Replace the `_handleRefresh` method body:

```dart
Future<void> _handleRefresh() async {
  _inState.add(UnlockProgressLoading());
  try {
    final sync = BlockSyncService();
    final usage = await sync.readTargetUsage();
    final threshold = await sync.readThreshold();
    final unlocked = await sync.isUnlockedToday();

    String targetAppName = '';
    bool hasCondition = false;
    final condition = await DbUnlockCondition.db.getActive();
    if (condition is TimeInAppCondition) {
      targetAppName = condition.targetAppName;
      hasCondition = true;
    }

    if (unlocked) {
      await DbBlockSession.db.markUnlocked();
    }

    _inState.add(UnlockProgressTracking(
      usageMinutes: usage,
      thresholdMinutes: threshold,
      targetAppName: targetAppName,
      unlocked: unlocked,
      hasCondition: hasCondition,
    ));
  } catch (e) {
    _inState.add(UnlockProgressTracking(
      usageMinutes: 0,
      thresholdMinutes: 60,
      targetAppName: '',
      unlocked: false,
      hasCondition: false,
    ));
  }
}
```

- [ ] **Step 1.3 — Run `flutter analyze` and verify no errors**

```bash
flutter analyze
```

Expected: no new errors. `BlockerPage` uses `state.targetAppName` — when no condition is set that page is unreachable (blocking requires a configured condition), so the empty string fallback is safe.

- [ ] **Step 1.4 — Commit**

```bash
git add lib/bloc/bloc_unlock_progress.dart
git commit -m "feat: add hasCondition flag to UnlockProgressTracking"
```

---

## Task 2: Add `_UnlockConditionCard` and wire into `AppUsagePage`

**Files:**
- Modify: `lib/ui/app_usage_page/app_usage_page.dart`

- [ ] **Step 2.1 — Add `_progressBloc` field and lifecycle to `_AppUsageBodyState`**

In `_AppUsageBodyState`, add the field declaration after `bool _accessibilityEnabled = false;`:

```dart
BlocUnlockProgress? _progressBloc;
```

In `didChangeDependencies`, add after the `_watchTimer ??=` line:

```dart
_progressBloc ??= BlocUnlockProgress();
```

In `dispose`, add before `super.dispose()`:

```dart
_progressBloc?.dispose();
```

- [ ] **Step 2.2 — Fire refresh on every timer tick**

In `_onTimerTick`, add at the top of the method body (before `_checkAccessibility()`):

```dart
_progressBloc?.inEvent.add(UnlockProgressEvent.refresh);
```

- [ ] **Step 2.3 — Insert `_UnlockConditionCard` into the Column**

Inside the `if (state is AppUsageStateLoaded)` branch, the `Column` currently contains:

```dart
Column(
  children: [
    Padding(                          // buttons row
      ...
    ),
    _AccessibilityBanner(...),
    if (state.apps.isEmpty) ...
    else Expanded(...)
  ],
)
```

Add `_UnlockConditionCard(bloc: _progressBloc!)` between the buttons `Padding` and `_AccessibilityBanner`:

```dart
Column(
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.block),
              label: const Text('Заблок. приложения'),
              onPressed: () =>
                  Navigator.pushNamed(context, routeAppPickerPage),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.lock_open),
              label: const Text('Условие'),
              onPressed: () => Navigator.pushNamed(
                  context, routeConditionConfigPage),
            ),
          ),
        ],
      ),
    ),
    _UnlockConditionCard(bloc: _progressBloc!),   // ← insert here
    _AccessibilityBanner(
      enabled: _accessibilityEnabled,
      onEnable: _openAccessibilitySettings,
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
)
```

- [ ] **Step 2.4 — Add the `_UnlockConditionCard` widget class**

Add this class at the bottom of `app_usage_page.dart` (after the existing `_formatMinutes` function):

```dart
class _UnlockConditionCard extends StatelessWidget {
  final BlocUnlockProgress bloc;

  const _UnlockConditionCard({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UnlockProgressState>(
      stream: bloc.outState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state is UnlockProgressTracking) {
          if (!state.hasCondition) return _buildEmpty();
          if (state.unlocked) return _buildUnlocked(state);
          return _buildInProgress(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_open, color: Colors.grey, size: 20),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Условие разблокировки не задано',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Нажми «Условие» чтобы настроить',
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInProgress(UnlockProgressTracking state) {
    final progress = state.thresholdMinutes == 0
        ? 1.0
        : (state.usageMinutes / state.thresholdMinutes).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x146366F1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x336366F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.targetAppName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      'Проведи ${state.thresholdMinutes} мин для разблокировки',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                '${state.usageMinutes}/${state.thresholdMinutes} м',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0x33E0E7FF),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            borderRadius: BorderRadius.circular(3),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildUnlocked(UnlockProgressTracking state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1410B981),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x4D10B981)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              color: Color(0xFF10B981), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Заблокированные приложения разблокированы',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065F46),
                      fontSize: 12),
                ),
                Text(
                  '${state.targetAppName} · ${state.thresholdMinutes} мин засчитано',
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF6EE7B7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2.5 — Add missing import for `BlocUnlockProgress`**

At the top of `app_usage_page.dart`, add:

```dart
import 'package:achievement/bloc/bloc_unlock_progress.dart';
```

- [ ] **Step 2.6 — Run `flutter analyze`**

```bash
flutter analyze
```

Expected: no errors.

- [ ] **Step 2.7 — Commit**

```bash
git add lib/ui/app_usage_page/app_usage_page.dart
git commit -m "feat: add UnlockConditionCard to AppUsagePage with progress visualization"
```

---

## Task 3: Manual smoke test

- [ ] **Step 3.1 — Verify "no condition" state**

Launch the app on device/emulator. Open the App Usage tab. If no condition is configured, the card shows:
> 🔓 Условие разблокировки не задано / Нажми «Условие» чтобы настроить

- [ ] **Step 3.2 — Verify "in progress" state**

Tap "Условие" → set a target app + threshold (e.g. 30 min). Save. Return to App Usage tab. Card shows the app name, `0/30 м`, and an empty progress bar.

- [ ] **Step 3.3 — Verify "unlocked" state**

Lower the threshold to 1 min (or advance `flutter.target_usage_minutes` in SharedPreferences via a debug tool). Wait for the 1-minute timer tick. Card turns green: "Заблокированные приложения разблокированы".
