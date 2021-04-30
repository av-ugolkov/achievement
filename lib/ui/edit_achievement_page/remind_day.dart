import '/core/changed_date_time_range.dart';
import '/core/enums.dart';
import '/model/remind_model.dart';
import '/core/formate_date.dart';
import 'package:flutter/material.dart';

class RemindDay extends StatefulWidget {
  final RemindModel remindModel;
  final ChangedDateTimeRange dateTimeRange;

  RemindDay({required this.remindModel, required this.dateTimeRange});

  @override
  _RemindDayState createState() => _RemindDayState();
}

class _RemindDayState extends State<RemindDay> {
  TypeRepition _typeRepition = TypeRepition.none;
  late List<DropdownMenuItem<TypeRepition>> _listTypeRepition;
  late RemindDateTime _remindDateTime;

  @override
  void initState() {
    super.initState();
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

    var dateNow = DateTime.now();
    _setRemindDateTime(
      RemindDateTime.fromDateTime(
        dateTime: dateNow.add(
          Duration(hours: 3),
        ),
      ),
    );
  }

  void _setRemindDateTime(RemindDateTime remindDateTime) {
    _remindDateTime = remindDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  if (_typeRepition == TypeRepition.week) {
                    _setRemindDateTime(RemindDateTime(
                        year: 1, month: 1, day: 1, hour: 12, minute: 0));
                  } else {
                    _setRemindDateTime(
                      RemindDateTime.fromDateTime(
                        dateTime: DateTime.now().add(
                          Duration(hours: 3),
                        ),
                      ),
                    );
                  }
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
    var items = <DateTime>[];
    for (var i = 0; i < 7; ++i) {
      items.add(
        DateTime(1, 1, i + 1, 12, 0),
      );
    }

    var weekDays = items
        .map(
          (item) => DropdownMenuItem<DateTime>(
            value: item,
            onTap: () {
              setState(() {
                _setRemindDateTime(RemindDateTime.fromDateTime(dateTime: item));
              });
            },
            child: Text(
              FormateDate.weekDayName(item),
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
        .toList();
    return DropdownButton<DateTime>(
      value: _remindDateTime.dateTime,
      onChanged: (DateTime? value) {
        setState(() {
          _setRemindDateTime(
            RemindDateTime.fromDateTime(dateTime: value!),
          );
        });
      },
      items: weekDays,
    );
  }

  GestureDetector _getDateButton() {
    return GestureDetector(
      onTap: () async {
        var newRemindDate = await showDatePicker(
            context: context,
            initialDate: _remindDateTime.dateTime,
            firstDate: widget.dateTimeRange.start,
            lastDate: widget.dateTimeRange.end);

        if (newRemindDate != null) {
          setState(() {
            _setRemindDateTime(
                RemindDateTime.fromDateTime(dateTime: newRemindDate));
            widget.remindModel.remindDateTime = _remindDateTime;
          });
        }
      },
      child: Text(
        FormateDate.yearNumMonthDay(_remindDateTime.dateTime),
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
          initialTime: TimeOfDay.fromDateTime(_remindDateTime.dateTime),
        );

        if (newTimeOfDay != null) {
          setState(() {
            _remindDateTime.hour = newTimeOfDay.hour;
            _remindDateTime.minute = newTimeOfDay.minute;
            widget.remindModel.remindDateTime = _remindDateTime;
          });
        }
      },
      child: Text(
        FormateDate.hour24Minute(_remindDateTime.dateTime),
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
