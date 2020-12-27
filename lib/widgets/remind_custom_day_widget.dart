import 'package:achievement/utils/formate_date.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RemindCustomDay extends StatefulWidget {
  Function(RemindCustomDay) _callbackRemove;

  RemindCustomDay(Function(RemindCustomDay) callbackRemove) {
    _callbackRemove = callbackRemove;
  }

  @override
  _RemindCustomDayState createState() => _RemindCustomDayState();
}

class _RemindCustomDayState extends State<RemindCustomDay> {
  DateTime _remindDate = DateTime.now().add(Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        widget._callbackRemove?.call(widget);
      },
      child: Container(
        child: Row(
          children: [
            TextButton(
                onPressed: () async {
                  var newRemindDate = await showDatePicker(
                      context: context,
                      initialDate: _remindDate,
                      firstDate: _remindDate.add(Duration(days: -1)),
                      lastDate: _remindDate.add(Duration(days: 10)));

                  if (newRemindDate != null) {
                    setState(() {
                      _remindDate = _remindDate = DateTime(
                          newRemindDate.year,
                          newRemindDate.month,
                          newRemindDate.day,
                          _remindDate.hour,
                          _remindDate.minute,
                          0);
                    });
                  }
                },
                child: Text(FormateDate.yearMonthDay(_remindDate))),
            TextButton(
                onPressed: () async {
                  var newTimeOfDay = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_remindDate));

                  if (newTimeOfDay != null) {
                    setState(() {
                      _remindDate = DateTime(
                          _remindDate.year,
                          _remindDate.month,
                          _remindDate.day,
                          newTimeOfDay.hour,
                          newTimeOfDay.minute,
                          0);
                    });
                  }
                },
                child: Text(FormateDate.hour24Minute(_remindDate)))
          ],
        ),
      ),
    );
  }
}
