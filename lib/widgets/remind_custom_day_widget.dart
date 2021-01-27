import 'package:achievement/enums.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:flutter/material.dart';

class RemindCustomDay extends StatefulWidget {
  final DateTimeRange dateRangeAchiv;
  DateTime get startAchiv => dateRangeAchiv.start;
  DateTime get endAchiv => dateRangeAchiv.end;

  final Function(RemindCustomDay) callbackRemove;

  final _RemindCustomDayState _remindCustomDayState = _RemindCustomDayState();
  DateTime get remindDateTime => _remindCustomDayState.remindDateTime;

  RemindCustomDay({Key key, this.dateRangeAchiv, this.callbackRemove})
      : super(key: key);

  @override
  _RemindCustomDayState createState() {
    return _remindCustomDayState;
  }
}

class _RemindCustomDayState extends State<RemindCustomDay> {
  TypeRepition _typeRepition = TypeRepition.none;
  DateTime remindDateTime;

  @override
  void initState() {
    super.initState();
    remindDateTime = widget.startAchiv.add(Duration(days: 1));
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton(
              height: 20,
              minWidth: 30,
              padding: EdgeInsets.symmetric(horizontal: 4),
              onPressed: () async {
                var newRemindDate = await showDatePicker(
                    context: context,
                    initialDate: remindDateTime,
                    firstDate: widget.startAchiv,
                    lastDate: widget.endAchiv);

                if (newRemindDate != null) {
                  setState(() {
                    remindDateTime = DateTime(
                        newRemindDate.year,
                        newRemindDate.month,
                        newRemindDate.day,
                        remindDateTime.hour,
                        remindDateTime.minute);
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
                });
              },
              items: TypeRepition.values.map<DropdownMenuItem>((value) {
                return DropdownMenuItem(
                  child: Text(
                    _getStringRepition(value),
                    style: TextStyle(fontSize: 13),
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
      case TypeRepition.month:
        return 'каждый месяц';
      case TypeRepition.year:
        return 'каждый год';
      default:
        return 'без повтора';
    }
  }
}
