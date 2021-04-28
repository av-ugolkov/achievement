import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/enums.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/core/formate_date.dart';
import 'package:flutter/material.dart';

class RemindDay extends StatefulWidget {
  final RemindModel remindModel;

  final Function(RemindDay) callbackRemove;

  final _RemindDayState _remindDayState = _RemindDayState();
  RemindDateTime get remindDateTime => _remindDayState.remindDateTime;

  RemindDay({Key? key, required this.remindModel, required this.callbackRemove})
      : super(key: key);

  @override
  _RemindDayState createState() {
    return _remindDayState;
  }

  void setRangeDateTime(ChangedDateTimeRange dateTimeRange) {
    _remindDayState.setRangeDateTime(dateTimeRange);
  }
}

class _RemindDayState extends State<RemindDay> {
  TypeRepition _typeRepition = TypeRepition.none;
  late List<DropdownMenuItem<TypeRepition>> _listTypeRepition;
  late ChangedDateTimeRange _dateTimeRange;
  late RemindDateTime remindDateTime;
  late String _day;

  void setRangeDateTime(ChangedDateTimeRange dateTimeRange) {
    _dateTimeRange = dateTimeRange;
    var dateNow = DateTime.now();
    remindDateTime = RemindDateTime.fromDateTime(
      dateTime: dateNow.add(
        Duration(hours: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _day = FormateDate.weekDayName(DateTime(1, 1, 1));
    _listTypeRepition =
        TypeRepition.values.map<DropdownMenuItem<TypeRepition>>((value) {
      return DropdownMenuItem<TypeRepition>(
          value: value,
          child: Text(
            _getStringRepition(value),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    remindDateTime = widget.remindDateTime;
    return Container(
      child: Dismissible(
        key: Key(widget.remindModel.hashCode.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          child: Container(
            width: 70,
            child: Icon(
              Icons.delete,
            ),
          ),
        ),
        onDismissed: (direction) {
          widget.callbackRemove.call(widget);
        },
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 36,
                child: DropdownButton<TypeRepition>(
                  value: _typeRepition,
                  onChanged: (TypeRepition? value) {
                    setState(() {
                      _typeRepition = value ?? TypeRepition.none;
                      widget.remindModel.typeRepition = _typeRepition;
                    });
                  },
                  items: _listTypeRepition,
                ),
              ),
              Container(
                height: 36,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _getRemindView(_typeRepition),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getRemindView(TypeRepition typeRepition) {
    switch (typeRepition) {
      case TypeRepition.day:
        return _getDayRepition();
      case TypeRepition.week:
        return _getWeekRepition();
      case TypeRepition.month:
      default:
        return _getNoneRepition();
    }
  }

  List<Widget> _getNoneRepition() {
    return <Widget>[
      _getDateButton(),
      _getTimeButton(),
    ];
  }

  List<Widget> _getDayRepition() {
    return <Widget>[_getTimeButton()];
  }

  List<Widget> _getWeekRepition() {
    return <Widget>[
      _getDay(),
      _getTimeButton(),
    ];
  }

  Widget _getDay() {
    var items = <String>[];
    for (var i = 0; i < 7; ++i) {
      var date = DateTime(1, 1, i + 1);
      items.add(FormateDate.weekDayName(date));
    }

    return DropdownButton<String>(
      value: _day,
      onChanged: (String? value) {
        setState(() {
          _day = value!;
        });
      },
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              onTap: () {
                setState(() {
                  _day = item;
                });
              },
              child: Text(
                item,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
          .toList(),
    );
  }

  GestureDetector _getDateButton() {
    return GestureDetector(
      onTap: () async {
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
      child: Text(
        FormateDate.yearNumMonthDay(remindDateTime.dateTime),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  GestureDetector _getTimeButton() {
    return GestureDetector(
      onTap: () async {
        var newTimeOfDay = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(remindDateTime.dateTime),
        );

        if (newTimeOfDay != null) {
          setState(() {
            remindDateTime.hour = newTimeOfDay.hour;
            remindDateTime.minute = newTimeOfDay.minute;
            widget.remindModel.remindDateTime = remindDateTime;
          });
        }
      },
      child: Text(
        FormateDate.hour24Minute(remindDateTime.dateTime),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStringRepition(TypeRepition typeRepition) {
    switch (typeRepition) {
      case TypeRepition.day:
        return 'каждый день';
      case TypeRepition.week:
        return 'каждую неделю';
      case TypeRepition.month:
        return 'каждый месяц';
      default:
        return 'без повтора';
    }
  }
}
