import 'dart:convert';

import 'package:achievement/enums.dart';

class RemindModel {
  int id;
  //TypeRemind typeRemind;
  TypeRepition typeRepition;
  RemindDateTime remindDateTime;

  static RemindModel get empty => RemindModel(id: -1, remindDateTime: null);

  RemindModel(
      {this.id,
      //this.typeRemind = TypeRemind.none,
      this.typeRepition = TypeRepition.none,
      this.remindDateTime});

  RemindModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    //typeRemind = TypeRemind.values[map['typeRemind']];
    typeRepition = TypeRepition.values[map['typeRepition']];
    remindDateTime = RemindDateTime.fromMap(map['dateTime']);
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['id'] = id;
    //map['typeRemind'] = typeRemind.index;
    map['typeRepition'] = typeRepition.index;
    map['day'] = jsonEncode(remindDateTime);
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

  factory RemindDateTime.fromDateTime({DateTime dateTime}) {
    return RemindDateTime(
        year: dateTime.year,
        month: dateTime.month,
        day: dateTime.day,
        hour: dateTime.hour,
        minute: dateTime.minute);
  }

  RemindDateTime.fromMap(Map<String, dynamic> map) {
    year = map['year'];
    month = map['month'];
    day = map['day'];
    hour = map['hour'];
    minute = map['minute'];
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['year'] = year;
    map['month'] = month;
    map['day'] = day;
    map['hour'] = hour;
    map['minute'] = minute;
    return map;
  }
}
