import 'package:achievement/core/formate_date.dart';
import 'package:achievement/data/entities/remind_entity.dart';
import 'package:achievement/data/model/remind_model.dart';
import 'package:flutter/material.dart';

class EditRemindDayBtn extends StatefulWidget {
  final RemindModel remindModel;

  EditRemindDayBtn({required this.remindModel});

  @override
  _EditRemindDayBtnState createState() => _EditRemindDayBtnState();
}

class _EditRemindDayBtnState extends State<EditRemindDayBtn> {
  List<DropdownMenuItem<int>> _weekDays = [];
  late RemindDateTime _remindDateTime;

  @override
  void initState() {
    super.initState();

    var days = <int>[];
    for (var i = 0; i < 7; ++i) {
      days.add(i + 1);
    }

    _weekDays = days
        .map(
          (day) => DropdownMenuItem<int>(
            value: day,
            onTap: () {
              setState(() {
                var now = DateTime.now();
                widget.remindModel.remindDateTime = RemindDateTime.fromDateTime(
                  dateTime: DateTime(1, 1, day, now.hour, now.minute),
                );
              });
            },
            child: Text(
              FormateDate.weekDayName(DateTime(1, 1, day, 12, 0)),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        )
        .toList();

    _remindDateTime = widget.remindModel.remindDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: _remindDateTime.dateTime.day,
      onChanged: (int? day) {
        setState(() {
          var now = DateTime.now();
          _remindDateTime = RemindDateTime.fromDateTime(
            dateTime: DateTime(1, 1, day!, now.hour, now.minute),
          );
          widget.remindModel.remindDateTime = _remindDateTime;
        });
      },
      items: _weekDays,
    );
  }
}
