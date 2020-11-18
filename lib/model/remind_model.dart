import 'package:achievement/enums.dart';

class RemindModel {
  int id;
  Period period;
  List<Day> days;
  List<Month> months;
  int hour;
  int minute;

  static RemindModel get empty => RemindModel(0, Period.none, null, null, 0, 0);

  RemindModel(
      this.id, this.period, this.days, this.months, this.hour, this.minute);

  RemindModel.fromMap(Map<String, dynamic> remind) {
    id = remind['id'];
    period = remind['period'];
    days = remind['days'];
    months = remind['months'];
    hour = remind['hour'];
    minute = remind['minute'];
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['id'] = id;
    map['period'] = period;
    map['days'] = days;
    map['months'] = months;
    map['hour'] = hour;
    map['minute'] = minute;
    return map;
  }
}
