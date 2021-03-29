import 'package:achievement/enums.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/standalone.dart' as tz;

class LocalNotification {
  static late LocalNotification _inst;

  final String channel = 'Achievement';

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static void init(SelectNotificationCallback selectNotification) {
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

  static Future<void> scheduleNotification(int id, String title, String body,
      DateTime scheduledDate, TypeRepition typeRepition) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0',
      _inst.channel,
      'channel description',
      //icon: 'flutter_devs',
      //largeIcon: DrawableResourceAndroidBitmap('flutter_devs'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    var dateTimeUtc = scheduledDate.toUtc();
    var tzSchedulerDate = tz.TZDateTime.utc(dateTimeUtc.year, dateTimeUtc.month,
        dateTimeUtc.day, dateTimeUtc.hour, dateTimeUtc.minute);
    await _inst.flutterLocalNotificationsPlugin.zonedSchedule(
        id, title, body, tzSchedulerDate, platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: _inst._matchDateTimeComponents(typeRepition));
  }

  static Future<void> periodicallyShow(
    int id,
    RepeatInterval repeatInterval, {
    String? title,
    String? body,
  }) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0',
      _inst.channel,
      'channel description',
      //icon: 'flutter_devs',
      //largeIcon: DrawableResourceAndroidBitmap('flutter_devs'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await _inst.flutterLocalNotificationsPlugin.periodicallyShow(
        id, title, body, repeatInterval, platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

  DateTimeComponents? _matchDateTimeComponents(TypeRepition typeRepition) {
    switch (typeRepition) {
      case TypeRepition.day:
        return DateTimeComponents.time;
      case TypeRepition.week:
        return DateTimeComponents.dayOfWeekAndTime;
      case TypeRepition.month:
      default:
        return null;
    }
  }

  static Future<List<PendingNotificationRequest>>
      pendingNotificationRequests() async {
    return await _inst.flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
  }

  static Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async {
    return await _inst.flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
  }

  static Future<void> cancelNotification(int id) async {
    await _inst.flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotification() async {
    await _inst.flutterLocalNotificationsPlugin.cancelAll();
  }
}
