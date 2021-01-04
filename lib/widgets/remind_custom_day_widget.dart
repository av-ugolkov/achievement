import 'package:achievement/enums.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:flutter/material.dart';

class RemindCustomDay extends StatefulWidget {
  DateTimeRange _dateRangeAchiv;
  DateTime get startAchiv => _dateRangeAchiv.start;
  DateTime get finishAchiv => _dateRangeAchiv.end;

  DateTime _remindDateTime;
  DateTime get remindDateTime => _remindDateTime;
  TypeRepition _typeRepition = TypeRepition.none;

  Function(RemindCustomDay) _callbackRemove;

  RemindCustomDay(
      DateTimeRange dateRangeAchiv, Function(RemindCustomDay) callbackRemove) {
    _dateRangeAchiv = dateRangeAchiv;
    _callbackRemove = callbackRemove;

    _remindDateTime = startAchiv.add(Duration(days: 1));
  }

  @override
  _RemindCustomDayState createState() => _RemindCustomDayState();
}

class _RemindCustomDayState extends State<RemindCustomDay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        widget._callbackRemove?.call(widget);
      },
      child: Container(
        height: 35,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton(
              height: 20,
              minWidth: 30,
              padding: EdgeInsets.symmetric(horizontal: 5),
              onPressed: () async {
                var newRemindDate = await showDatePicker(
                    context: context,
                    initialDate: widget._remindDateTime,
                    firstDate: widget._dateRangeAchiv.start,
                    lastDate: widget._dateRangeAchiv.end);

                if (newRemindDate != null) {
                  setState(() {
                    widget._remindDateTime = DateTime(
                        newRemindDate.year,
                        newRemindDate.month,
                        newRemindDate.day,
                        widget._remindDateTime.hour,
                        widget._remindDateTime.minute);
                  });
                }
              },
              shape: UnderlineInputBorder(),
              child: Text(
                FormateDate.yearMonthDay(widget._remindDateTime),
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
            FlatButton(
              height: 20,
              minWidth: 30,
              padding: EdgeInsets.symmetric(horizontal: 5),
              onPressed: () async {
                var newTimeOfDay = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay.fromDateTime(widget._remindDateTime));

                if (newTimeOfDay != null) {
                  setState(() {
                    widget._remindDateTime = DateTime(
                        widget._remindDateTime.year,
                        widget._remindDateTime.month,
                        widget._remindDateTime.day,
                        newTimeOfDay.hour,
                        newTimeOfDay.minute);
                  });
                }
              },
              shape: UnderlineInputBorder(),
              child: Text(
                FormateDate.hour24Minute(widget._remindDateTime),
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
            DropdownButton(
              value: widget._typeRepition,
              onChanged: (value) {
                setState(() {
                  widget._typeRepition = value;
                });
              },
              items: TypeRepition.values.map<DropdownMenuItem>((value) {
                return DropdownMenuItem(
                  child: Text(_getStringRepition(value)),
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
      case TypeRepition.month:
        return 'каждый месяц';
      case TypeRepition.year:
        return 'каждый год';
      default:
        return 'без повтора';
    }
  }
}
