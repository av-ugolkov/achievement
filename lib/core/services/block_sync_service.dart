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
