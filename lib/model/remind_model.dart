import 'package:achievement/enums.dart';

class RemindModel {
  int id;
  TypeRemind typeRemind;
  String remind;

  static RemindModel get empty =>
      RemindModel(id: -1, typeRemind: TypeRemind.none, remind: '');

  RemindModel({this.id, this.typeRemind, this.remind});

  RemindModel.fromMap(Map<String, dynamic> remind) {
    id = remind['id'];
    typeRemind = remind['typeRemind'];
    remind = remind['remind'];
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['id'] = id;
    map['typeRemind'] = typeRemind;
    map['remind'] = remind;
    return map;
  }
}

class RemindWeekDayModel {
  List<Day> days;
  int hour;
  int minute;

  static RemindWeekDayModel get empty =>
      RemindWeekDayModel(days: null, hour: 0, minute: 0);

  RemindWeekDayModel({
    this.days,
    this.hour,
    this.minute,
  });

  RemindWeekDayModel.fromMap(Map<String, dynamic> remind) {
    days = remind['days'];
    hour = remind['hour'];
    minute = remind['minute'];
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['days'] = days;
    map['hour'] = hour;
    map['minute'] = minute;
    return map;
  }
}
