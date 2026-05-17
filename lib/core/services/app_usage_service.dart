import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:app_usage/app_usage.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:achievement/core/utils.dart';
import 'package:achievement/data/model/app_usage_model.dart';
import 'package:achievement/core/services/block_sync_service.dart';

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
      await BlockSyncService().writeAchievementUsage(achievementMinutes);

      final installedApps = await InstalledApps.getInstalledApps(false, true);

      final iconMap = <String, Uint8List>{};
      final nameMap = <String, String>{};
      for (final app in installedApps) {
        nameMap[app.packageName] = app.name;
        final icon = app.icon;
        if (icon != null) iconMap[app.packageName] = icon;
      }

      final result = <AppUsageModel>[];
      for (final entry in usageMap.entries) {
        final name = nameMap[entry.key];
        if (name == null) continue;
        result.add(AppUsageModel(
          appName: name,
          packageName: entry.key,
          icon: iconMap[entry.key],
          usageMinutes: entry.value,
        ));
      }

      result.sort((a, b) => b.usageMinutes.compareTo(a.usageMinutes));
      return result;
    } catch (_) {
      return [];
    }
  }
}
