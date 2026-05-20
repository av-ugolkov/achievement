# Design: Unlock Condition Summary Card

**Date:** 2026-05-20  
**Scope:** Add a visual card to `AppUsagePage` showing the current unlock condition (target app + progress toward threshold).

---

## Goal

Users cannot tell at a glance what unlock condition is set. After configuring a condition in `ConditionConfigPage`, the `AppUsagePage` shows no feedback — the "Условие" button gives no indication that anything is configured. The card fixes this by making the active condition immediately visible.

---

## Placement

A new `_UnlockConditionCard` widget is inserted between the action buttons row and the `_AccessibilityBanner` in `AppUsagePage`. It is always visible when `AppUsageStateLoaded` is active.

```
[Кнопки: Заблок. приложения | Условие]
[_UnlockConditionCard]               ← new
[_AccessibilityBanner]
[ListView: app list]
```

---

## Three States

### 1. No condition configured
Shown when `BlocUnlockProgress` emits `UnlockProgressLoading` or there is no active condition (target app is empty).

```
┌─────────────────────────────────────┐
│  🔓  Условие разблокировки не задано │
│      Нажми «Условие» чтобы настроить │
└─────────────────────────────────────┘
```
Style: dashed border, grey background, muted text.

### 2. In progress
Shown when `UnlockProgressTracking.unlocked == false`.

```
┌─────────────────────────────────────┐
│  [icon]  YouTube            12/30 м │
│          Проведи 30 мин             │
│  ████████░░░░░░░░░░░░  40%          │
└─────────────────────────────────────┘
```
Style: indigo tint border + background, `LinearProgressIndicator`, minute counter.

### 3. Unlocked today
Shown when `UnlockProgressTracking.unlocked == true`.

```
┌─────────────────────────────────────┐
│  ✅  Заблокированные приложения      │
│       разблокированы                │
│       YouTube · 30 мин засчитано    │
└─────────────────────────────────────┘
```
Style: green tint border + background.

---

## Data Source

`_UnlockConditionCard` subscribes to `BlocUnlockProgress.outState` — the same BLOC already used by `BlockerPage`. No new BLOC or service needed.

`AppUsagePage` already has a `Timer.periodic(1 min)` that fires `AppUsageEvent.refresh`. The card adds its own `BlocUnlockProgress` instance (or receives one via `BlocProvider`) and fires `UnlockProgressEvent.refresh` on the same cadence. The timer lives in `_AppUsageBodyState.didChangeDependencies` and is cancelled in `dispose()`.

---

## Implementation Scope

**New widget:** `_UnlockConditionCard` — private to `app_usage_page.dart` (no new file needed).

**Modified file:** `lib/ui/app_usage_page/app_usage_page.dart`
- Add `BlocUnlockProgress _progressBloc` field to `_AppUsageBodyState`
- Instantiate and dispose it alongside the existing timer
- Fire `UnlockProgressEvent.refresh` on each timer tick
- Insert `_UnlockConditionCard(bloc: _progressBloc)` in the `Column` children

**No changes needed to:**
- `BlocUnlockProgress` (already implemented)
- `BlockSyncService` (already has `readTargetUsage`, `isUnlockedToday`)
- `ConditionConfigPage`, `BlockerPage`, or any BLOC

---

## Edge Cases

| Case | Handling |
|---|---|
| Condition not yet configured | Show "empty" state — no crash, graceful fallback |
| Target app uninstalled | Show package name instead of app name (already handled by `UnlockProgressTracking.targetAppName`) |
| Timer fires while page disposed | `BlocUnlockProgress.dispose()` called in `_AppUsageBodyState.dispose()` |
| `BlocUnlockProgress` already used in `BlockerPage` | Each page gets its own instance — no shared state conflict |
