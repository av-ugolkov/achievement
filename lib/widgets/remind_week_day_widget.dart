import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RemindWeekDay extends StatefulWidget {
  final String title;

  RemindWeekDay({Key key, this.title}) : super(key: key);

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
            child: Text(widget.title),
          ),
          Container(
            width: 50,
            child: Checkbox(
                value: _isSelect,
                onChanged: (value) {
                  setState(() {
                    _isSelect = value;
                  });
                }),
          ),
          Container(
            width: 100,
            child: TextButton(
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
}
