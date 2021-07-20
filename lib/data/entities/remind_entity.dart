import 'package:achievement/core/enums.dart';
import 'package:achievement/core/formate_date.dart';

class RemindEntity {
  late int id;
  late TypeRepition typeRepition;
  late RemindDateTime remindDateTime;

  RemindEntity(
      {required this.id,
      required this.remindDateTime,
      this.typeRepition = TypeRepition.none});
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

  RemindDateTime.fromJson(Map<String, dynamic> map)
      : year = map['year'] as int,
        month = map['month'] as int,
        day = map['day'] as int,
        hour = map['hour'] as int,
        minute = map['minute'] as int;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['year'] = year;
    map['month'] = month;
    map['day'] = day;
    map['hour'] = hour;
    map['minute'] = minute;
    return map;
  }

  String get date => FormateDate.yearMonthDay(dateTime);

  String get time => '$hour:${minute == 0 ? '00' : minute}';

  @override
  String toString() {
    return '$year-$month-$day:$hour:${minute == 0 ? '00' : minute}';
  }
}
