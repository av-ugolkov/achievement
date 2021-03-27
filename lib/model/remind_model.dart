import 'dart:convert';
import 'package:achievement/enums.dart';

class RemindModel {
  late int id;
  late TypeRepition typeRepition;
  late RemindDateTime remindDateTime;

  static RemindModel get empty => RemindModel(
      id: -1,
      remindDateTime: RemindDateTime(
        year: 0,
        month: 0,
        day: 0,
        hour: 0,
        minute: 0,
      ));

  RemindModel(
      {required this.id,
      this.typeRepition = TypeRepition.none,
      required this.remindDateTime});

  RemindModel.fromMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        typeRepition = TypeRepition.values[map['typeRepition'] as int],
        remindDateTime = RemindDateTime.fromMap(
            jsonDecode(map['dateTime'] as String) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['typeRepition'] = typeRepition.index;
    map['dateTime'] = jsonEncode(remindDateTime.toMap());
    return map;
  }
}

class RemindDateTime {
  late int year;
  late int month;
  late int day;
  late int hour;
  late int minute;

  DateTime get dateTime => DateTime(year, month, day, hour, minute);

  RemindDateTime({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
  });

  RemindDateTime.fromDateTime({required DateTime dateTime})
      : year = dateTime.year,
        month = dateTime.month,
        day = dateTime.day,
        hour = dateTime.hour,
        minute = dateTime.minute;

  RemindDateTime.fromMap(Map<String, dynamic> map)
      : year = map['year'] as int,
        month = map['month'] as int,
        day = map['day'] as int,
        hour = map['hour'] as int,
        minute = map['minute'] as int;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['year'] = year;
    map['month'] = month;
    map['day'] = day;
    map['hour'] = hour;
    map['minute'] = minute;
    return map;
  }

  @override
  String toString() {
    return '$year-$month-$day:$hour:$minute';
  }
}
