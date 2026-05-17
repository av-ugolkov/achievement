import 'dart:io';
import 'dart:typed_data';
import 'package:app_usage/app_usage.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:achievement/data/model/app_usage_model.dart';

class AppUsageService {
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

      final installedApps = await InstalledApps.getInstalledApps(true, true);

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
