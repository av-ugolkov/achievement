import 'package:achievement/enums.dart';

class RemindModel {
  Period period;
  List<Day> days;
  List<Month> months;
  int hour;
  int minute;

  RemindModel(this.period, this.days, this.months, this.hour, this.minute);

  RemindModel.fromMap(Map<String, dynamic> remind) {
    period = remind['period'];
    days = remind['days'];
    months = remind['months'];
    hour = remind['hour'];
    minute = remind['minute'];
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['period'] = period;
    map['days'] = days;
    map['months'] = months;
    map['hour'] = hour;
    map['minute'] = minute;
    return map;
  }
}
