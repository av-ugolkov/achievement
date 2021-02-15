import 'package:achievement/enums.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:flutter/material.dart';

class RemindCustomDay extends StatefulWidget {
  final RemindModel remindModel;

  final Function(RemindCustomDay) callbackRemove;

  final _RemindCustomDayState _remindCustomDayState = _RemindCustomDayState();
  RemindDateTime get remindDateTime => _remindCustomDayState.remindDateTime;

  RemindCustomDay({Key key, this.remindModel, this.callbackRemove})
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
  RemindDateTime remindDateTime;

  void setRangeDateTime(DateTimeRange dateTimeRange) {
    _dateTimeRange = dateTimeRange;
    remindDateTime =
        RemindDateTime.fromDateTime(dateTime: _dateTimeRange.start);
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
                    initialDate: remindDateTime.dateTime,
                    firstDate: _dateTimeRange.start,
                    lastDate: _dateTimeRange.end);

                if (newRemindDate != null) {
                  setState(() {
                    remindDateTime =
                        RemindDateTime.fromDateTime(dateTime: newRemindDate);
                    widget.remindModel.remindDateTime = remindDateTime;
                  });
                }
              },
              shape: UnderlineInputBorder(),
              child: Text(
                FormateDate.yearMonthDay(remindDateTime.dateTime),
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
                    initialTime:
                        TimeOfDay.fromDateTime(remindDateTime.dateTime));

                if (newTimeOfDay != null) {
                  setState(() {
                    remindDateTime.hour = newTimeOfDay.hour;
                    remindDateTime.hour = newTimeOfDay.minute;
                    widget.remindModel.remindDateTime = remindDateTime;
                  });
                }
              },
              shape: UnderlineInputBorder(),
              child: Text(
                FormateDate.hour24Minute(remindDateTime.dateTime),
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
                  widget.remindModel.typeRepition = _typeRepition;
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
