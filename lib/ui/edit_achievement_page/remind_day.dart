import 'edit_remind_date_btn.dart';
import 'edit_remind_day_btn.dart';
import 'edit_remind_time_btn.dart';
import '/core/changed_date_time_range.dart';
import '/core/enums.dart';
import '/model/remind_model.dart';
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
  //late RemindDateTime _remindDateTime;

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

    /*var dateNow = DateTime.now();
    _setRemindDateTime(
      RemindDateTime.fromDateTime(
        dateTime: dateNow.add(
          Duration(hours: 3),
        ),
      ),
    );*/
  }

  /*void _setRemindDateTime(RemindDateTime remindDateTime) {
    _remindDateTime = remindDateTime;
  }*/

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
                  /*if (_typeRepition == TypeRepition.week) {
                    _setRemindDateTime(RemindDateTime(
                        year: 1, month: 1, day: 1, hour: 12, minute: 0));
                    widget.remindModel.remindDateTime = _remindDateTime;
                  } else {
                    _setRemindDateTime(
                      RemindDateTime.fromDateTime(
                        dateTime: DateTime.now().add(
                          Duration(hours: 3),
                        ),
                      ),
                    );
                  }*/
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
      EditRemindDateBtn(
        remindModel: widget.remindModel,
        dateTimeRange: widget.dateTimeRange,
      ),
      EditRemindTimeBtn(
        remindModel: widget.remindModel,
        dateTimeRange: widget.dateTimeRange,
      ),
    ];
  }

  List<Widget> _getDayRepition() {
    return <Widget>[
      EditRemindTimeBtn(
        remindModel: widget.remindModel,
        dateTimeRange: widget.dateTimeRange,
      )
    ];
  }

  List<Widget> _getWeekRepition() {
    return <Widget>[
      EditRemindDayBtn(remindModel: widget.remindModel),
      EditRemindTimeBtn(
        remindModel: widget.remindModel,
        dateTimeRange: widget.dateTimeRange,
      ),
    ];
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
