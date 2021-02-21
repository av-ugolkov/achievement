import 'dart:convert';
import 'package:achievement/enums.dart';

class RemindModel {
  int id;
  TypeRepition typeRepition;
  RemindDateTime remindDateTime;

  static RemindModel get empty => RemindModel(id: -1, remindDateTime: null);

  RemindModel(
      {this.id, this.typeRepition = TypeRepition.none, this.remindDateTime});

  RemindModel.fromMap(Map<String, dynamic> map) {
    id = map['id'] as int;
    typeRepition = TypeRepition.values[map['typeRepition'] as int];
    var dateTime =
        jsonDecode(map['dateTime'] as String) as Map<String, dynamic>;
    remindDateTime = RemindDateTime.fromMap(dateTime);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['typeRepition'] = typeRepition.index;
    map['dateTime'] = jsonEncode(remindDateTime.toMap());
    return map;
  }
}

class RemindDateTime {
  int year;
  int month;
  int day;
  int hour;
  int minute;

  DateTime get dateTime => DateTime(year, month, day, hour, minute);

  RemindDateTime({this.year, this.month, this.day, this.hour, this.minute});

  RemindDateTime.fromDateTime({DateTime dateTime}) {
    year = dateTime.year;
    month = dateTime.month;
    day = dateTime.day;
    hour = dateTime.hour;
    minute = dateTime.minute;
  }

  RemindDateTime.fromMap(Map<String, dynamic> map) {
    year = map['year'] as int;
    month = map['month'] as int;
    day = map['day'] as int;
    hour = map['hour'] as int;
    minute = map['minute'] as int;
  }

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
