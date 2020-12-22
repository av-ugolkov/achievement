import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RemindDay extends StatefulWidget {
  String _title;

  RemindDay({@required String title}) {
    _title = title;
  }

  @override
  _RemindDayState createState() => _RemindDayState(_title);
}

class _RemindDayState extends State<RemindDay> {
  String _title;
  bool _isSelect = false;
  TimeOfDay _time = TimeOfDay(hour: 12, minute: 0);
  _RemindDayState(String title) {
    _title = title;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 200,
          child: Text(_title),
        ),
        Checkbox(
            value: _isSelect,
            onChanged: (value) {
              setState(() {
                _isSelect = value;
              });
            }),
        TextButton(
          onPressed: _isSelect
              ? () async {
                  var newTime = await showTimePicker(
                      context: context, initialTime: _time);
                  setState(() {
                    if (newTime != null) {
                      _time = newTime;
                    }
                  });
                }
              : null,
          child: Text(_time.format(context)),
        )
      ],
    );
  }
}