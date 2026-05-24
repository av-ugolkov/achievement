import 'dart:convert';
import 'dart:io';
import 'package:app_usage/app_usage.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:achievement/core/utils.dart';
import 'package:achievement/data/model/app_usage_model.dart';
import 'package:achievement/core/services/block_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _blockerChannel = MethodChannel('com.ugolkov.achievement/blocker');

class AppUsageService {
  static String get _watchlistPath => '${docsDir.path}/watchlist.json';

  // Returns packageName -> appName mapping.
  Future<Map<String, String>> loadWatchlist() async {
    final file = File(_watchlistPath);
    if (!await file.exists()) return {};
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map) return Map<String, String>.from(decoded);
      // Migrate legacy list format
      if (decoded is List) {
        return {for (final pkg in decoded) pkg as String: pkg};
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> saveWatchlist(Map<String, String> watchlist) async {
    final file = File(_watchlistPath);
    await file.writeAsString(jsonEncode(watchlist));
  }


  static Future<Set<String>> getLaunchablePackages() async {
    try {
      final list = await _blockerChannel.invokeListMethod<String>('getLaunchablePackages');
      return list?.toSet() ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<bool> hasPermission() async {
    if (Platform.isIOS) return false;
    try {
      final now = DateTime.now();
      await AppUsage()
          .getAppUsage(now.subtract(const Duration(seconds: 1)), now);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<AppUsageModel>> fetchTodayUsage() async {
    if (Platform.isIOS) return [];
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Reset usage if the stored date is from a previous day.
      final prefs = await SharedPreferences.getInstance();
      final storedDay = prefs.getString('flutter.achievement_usage_day');
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      if (storedDay != todayStr) {
        await prefs.setString('flutter.achievement_usage_day', todayStr);
        await BlockSyncService().writeAchievementUsage(0);
      }

      final usageInfos = await AppUsage().getAppUsage(startOfDay, now);
      if (usageInfos.isEmpty) return [];

      final usageMap = <String, int>{};
      for (final info in usageInfos) {
        final mins = info.usage.inMinutes;
        if (mins > 0) {
          usageMap[info.packageName] = mins;
        }
      }
      if (usageMap.isEmpty) return [];

      const kAchievementPackage = 'com.ugolkov.achievement';
      final achievementMinutes = usageMap[kAchievementPackage] ?? 0;
      final sync = BlockSyncService();
      await sync.writeAchievementUsage(achievementMinutes);

      final targetPackage = await sync.readTargetPackage();
      if (targetPackage.isNotEmpty) {
        await sync.writeTargetUsage(usageMap[targetPackage] ?? 0);
      }

      final launchable = await AppUsageService.getLaunchablePackages();
      final installedApps = await InstalledApps.getInstalledApps(false, true);

      final result = <AppUsageModel>[];
      for (final app in installedApps) {
        if (app.packageName == kAchievementPackage) continue;
        if (!launchable.contains(app.packageName)) continue;
        result.add(AppUsageModel(
          appName: app.name,
          packageName: app.packageName,
          icon: app.icon,
          usageMinutes: usageMap[app.packageName] ?? 0,
        ));
      }

      result.sort((a, b) => b.usageMinutes.compareTo(a.usageMinutes));
      return result;
    } catch (_) {
      return [];
    }
  }
}
