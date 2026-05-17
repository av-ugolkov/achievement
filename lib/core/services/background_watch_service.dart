import 'package:achievement/core/services/app_usage_service.dart';
import 'package:achievement/core/utils.dart' as utils;
import 'package:app_usage/app_usage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

const String kWatchTaskUniqueName = 'achievementWatchlistCheck';
const String kWatchTaskName = 'checkWatchedApps';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      utils.docsDir = await getApplicationDocumentsDirectory();

      final service = AppUsageService();
      final watchlist = await service.loadWatchlist();
      if (watchlist.isEmpty) return true;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final usageInfos = await AppUsage().getAppUsage(startOfDay, now);

      final underThreshold = usageInfos
          .where((info) =>
              watchlist.containsKey(info.packageName) &&
              info.usage.inMinutes < 1440)
          .map((info) => watchlist[info.packageName]!)
          .toList();

      if (underThreshold.isEmpty) return true;

      final notifications = FlutterLocalNotificationsPlugin();
      await notifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('icon_achievement'),
        ),
      );
      await notifications.show(
        id: 999,
        title: 'Наблюдаемые приложения',
        body: underThreshold.join(', '),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            '0',
            'achievement',
            channelDescription: 'channel description',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (_) {
      // Background tasks must not propagate exceptions
    }
    return true;
  });
}
