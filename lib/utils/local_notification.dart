import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  static LocalNotification _inst;

  final String channel = 'Achievement';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static void init({SelectNotificationCallback selectNotification}) {
    _inst = LocalNotification._(selectNotification);
  }

  LocalNotification._(SelectNotificationCallback selectNotification) {
    var initSettingAndroid = AndroidInitializationSettings('icon_achievement');
    var initSettingIOS = IOSInitializationSettings();

    var initSetting = InitializationSettings(
        android: initSettingAndroid, iOS: initSettingIOS);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: selectNotification);
  }

  static scheduleNotification(DateTime scheduledNotificationDateTime) async {
    await _inst._scheduleNotification(scheduledNotificationDateTime);
  }

  Future<void> _scheduleNotification(
      DateTime scheduledNotificationDateTime) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0',
      channel,
      'channel description',
      icon: 'flutter_devs',
      largeIcon: DrawableResourceAndroidBitmap('flutter_devs'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
