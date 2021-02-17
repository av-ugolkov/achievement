import 'package:achievement/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/standalone.dart' as tz;

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

  static scheduleNotification(
      {@required int id,
      @required DateTime scheduledDate,
      String title,
      String body,
      TypeRepition typeRepition = TypeRepition.none}) async {
    await _inst._scheduleNotification(
        id: id,
        scheduledDate: scheduledDate,
        title: title,
        body: body,
        typeRepition: typeRepition);
  }

  Future<void> _scheduleNotification(
      {int id,
      String title,
      String body,
      DateTime scheduledDate,
      TypeRepition typeRepition}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0',
      channel,
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
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id, title, body, tzSchedulerDate, platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: _matchDateTimeComponents(typeRepition));
  }

  dynamic _matchDateTimeComponents(TypeRepition typeRepition) {
    switch (typeRepition) {
      case TypeRepition.day:
        return DateTimeComponents.time;
      case TypeRepition.week:
        return DateTimeComponents.dayOfWeekAndTime;
      case TypeRepition.month:
      case TypeRepition.year:
      default:
        return null;
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
