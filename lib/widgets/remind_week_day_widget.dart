import 'package:achievement/model/remind_model.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RemindWeekDay extends StatefulWidget {
  final DayModel dayModel;

  RemindWeekDay({Key key, this.dayModel}) : super(key: key);

  @override
  _RemindWeekDayState createState() => _RemindWeekDayState();
}

class _RemindWeekDayState extends State<RemindWeekDay> {
  bool _isSelect = false;
  TimeOfDay _time = TimeOfDay(hour: 12, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            child: Text(
                FormateDate.weekDayName(DateTime(1, 1, widget.dayModel.day))),
          ),
          Container(
            width: 50,
            child: Checkbox(
                value: _isSelect,
                onChanged: (value) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isSelect = value;
                    _setTime(_isSelect ? _time : null);
                  });
                }),
          ),
          Container(
            width: 100,
            child: TextButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (_isSelect) {
                  var newTime = await showTimePicker(
                      context: context, initialTime: _time);
                  setState(() {
                    if (newTime != null) {
                      _time = newTime;
                      _setTime(_time);
                    }
                  });
                }
              },
              child: Text(
                _time.format(context),
                style: TextStyle(fontSize: 14),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _setTime(TimeOfDay time) {
    widget.dayModel.hour = time?.hour;
    widget.dayModel.minute = time?.minute;
  }
}
