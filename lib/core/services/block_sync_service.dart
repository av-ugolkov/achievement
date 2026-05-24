import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BlockSyncService {
  static const _blockListKey = 'block_list';
  static const _thresholdKey = 'threshold_minutes';
  static const _achievementUsageKey = 'achievement_usage_minutes';
  static const _unlockConditionTypeKey = 'unlock_condition_type';
  static const _targetPackageKey = 'target_package';
  static const _targetUsageDayKey = 'target_usage_day';
  static const _targetUsageMinutesKey = 'target_usage_minutes';
  static const _unlockedDayKey = 'unlocked_day';

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

  Future<void> writeUnlockConditionType(int type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unlockConditionTypeKey, type);
  }

  Future<void> writeTargetPackage(String pkg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_targetPackageKey, pkg);
  }

  Future<String> readTargetPackage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_targetPackageKey) ?? '';
  }

  Future<void> writeTargetUsage(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await prefs.setString(_targetUsageDayKey, today);
    await prefs.setInt(_targetUsageMinutesKey, minutes);
  }

  Future<int> readTargetUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDay = prefs.getString(_targetUsageDayKey) ?? '';
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (storedDay != today) return 0;
    return prefs.getInt(_targetUsageMinutesKey) ?? 0;
  }

  Future<bool> isUnlockedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedDay = prefs.getString(_unlockedDayKey) ?? '';
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return unlockedDay == today;
  }

  Future<void> markUnlockedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await prefs.setString(_unlockedDayKey, today);
  }

  Future<void> clearCondition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unlockConditionTypeKey);
    await prefs.remove(_targetPackageKey);
  }
}
