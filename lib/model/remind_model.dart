import 'dart:convert';

import 'package:achievement/enums.dart';

class RemindModel {
  int id;
  TypeRemind typeRemind;
  List<DayModel> reminds = [];

  static RemindModel get empty =>
      RemindModel(id: -1, typeRemind: TypeRemind.none, reminds: null);

  RemindModel({this.id, this.typeRemind, this.reminds});

  RemindModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    typeRemind = TypeRemind.values[map['typeRemind']];
    var mapReminds = jsonDecode(map['reminds']);
    for (var mapRemind in mapReminds) {
      reminds.add(DayModel.fromMap(mapRemind));
    }
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['id'] = id;
    map['typeRemind'] = typeRemind.index;
    map['reminds'] = jsonEncode(reminds.map((value) {
      return value.toMap();
    }).toList());
    return map;
  }
}

class DayModel {
  dynamic day;
  int hour;
  int minute;

  DayModel({this.day, this.hour, this.minute});

  DayModel.fromMap(Map<String, dynamic> map) {
    day = map['day'];
    hour = map['hour'];
    minute = map['minute'];
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['day'] = day;
    map['hour'] = hour;
    map['minute'] = minute;
    return map;
  }
}
