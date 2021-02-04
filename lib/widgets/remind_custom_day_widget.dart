import 'package:achievement/enums.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:flutter/material.dart';

class RemindCustomDay extends StatefulWidget {
  final DayModel dayModel;

  final Function(RemindCustomDay) callbackRemove;

  final _RemindCustomDayState _remindCustomDayState = _RemindCustomDayState();
  DateTime get remindDateTime => _remindCustomDayState.remindDateTime;

  RemindCustomDay({Key key, this.dayModel, this.callbackRemove})
      : super(key: key);

  @override
  _RemindCustomDayState createState() {
    return _remindCustomDayState;
  }

  void setRangeDateTime(DateTimeRange dateTimeRange) {
    _remindCustomDayState.setRangeDateTime(dateTimeRange);
  }
}

class _RemindCustomDayState extends State<RemindCustomDay> {
  TypeRepition _typeRepition = TypeRepition.none;
  DateTimeRange _dateTimeRange;
  DateTime remindDateTime;

  void setRangeDateTime(DateTimeRange dateTimeRange) {
    _dateTimeRange = dateTimeRange;
    remindDateTime = _dateTimeRange.start.add(Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    remindDateTime = widget.remindDateTime;
    return GestureDetector(
      onLongPress: () {
        widget.callbackRemove?.call(widget);
      },
      child: Container(
        height: 35,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlatButton(
              height: 20,
              minWidth: 30,
              padding: EdgeInsets.symmetric(horizontal: 4),
              onPressed: () async {
                var newRemindDate = await showDatePicker(
                    context: context,
                    initialDate: remindDateTime,
                    firstDate: _dateTimeRange.start,
                    lastDate: _dateTimeRange.end);

                if (newRemindDate != null) {
                  setState(() {
                    remindDateTime = DateTime(
                        newRemindDate.year,
                        newRemindDate.month,
                        newRemindDate.day,
                        remindDateTime.hour,
                        remindDateTime.minute);
                    widget.dayModel.day = DateTime(remindDateTime.year,
                        remindDateTime.month, remindDateTime.day);
                  });
                }
              },
              shape: UnderlineInputBorder(),
              child: Text(
                FormateDate.yearMonthDay(remindDateTime),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                ),
              ),
            ),
            FlatButton(
              height: 20,
              minWidth: 30,
              padding: EdgeInsets.symmetric(horizontal: 4),
              onPressed: () async {
                var newTimeOfDay = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(remindDateTime));

                if (newTimeOfDay != null) {
                  setState(() {
                    remindDateTime = DateTime(
                        remindDateTime.year,
                        remindDateTime.month,
                        remindDateTime.day,
                        newTimeOfDay.hour,
                        newTimeOfDay.minute);
                    widget.dayModel.hour = remindDateTime.hour;
                    widget.dayModel.minute = remindDateTime.minute;
                  });
                }
              },
              shape: UnderlineInputBorder(),
              child: Text(
                FormateDate.hour24Minute(remindDateTime),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                ),
              ),
            ),
            DropdownButton(
              value: _typeRepition,
              onChanged: (value) {
                setState(() {
                  _typeRepition = value;
                  widget.dayModel.typeRepition = _typeRepition;
                });
              },
              items: TypeRepition.values.map<DropdownMenuItem>((value) {
                return DropdownMenuItem(
                  child: Text(
                    _getStringRepition(value),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                  value: value,
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  String _getStringRepition(TypeRepition typeRepition) {
    switch (typeRepition) {
      case TypeRepition.week:
        return 'каждую неделю';
      case TypeRepition.month:
        return 'каждый месяц';
      case TypeRepition.year:
        return 'каждый год';
      default:
        return 'без повтора';
    }
  }
}
