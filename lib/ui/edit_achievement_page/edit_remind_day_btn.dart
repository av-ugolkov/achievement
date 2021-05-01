import 'package:achievement/core/formate_date.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:flutter/material.dart';

class EditRemindDayBtn extends StatefulWidget {
  final RemindModel remindModel;

  EditRemindDayBtn({required this.remindModel});

  @override
  _EditRemindDayBtnState createState() => _EditRemindDayBtnState();
}

class _EditRemindDayBtnState extends State<EditRemindDayBtn> {
  List<DropdownMenuItem<DateTime>> _weekDays = [];
  RemindDateTime _remindDateTime =
      RemindDateTime(year: 1, month: 1, day: 1, hour: 12, minute: 0);

  @override
  void initState() {
    super.initState();

    var items = <DateTime>[];
    for (var i = 0; i < 7; ++i) {
      items.add(
        DateTime(1, 1, i + 1, 12, 0),
      );
    }

    _weekDays = items
        .map(
          (item) => DropdownMenuItem<DateTime>(
            value: item,
            onTap: () {
              setState(() {
                widget.remindModel.remindDateTime =
                    RemindDateTime.fromDateTime(dateTime: item);
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
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<DateTime>(
      value: _remindDateTime.dateTime,
      onChanged: (DateTime? value) {
        setState(() {
          _remindDateTime = RemindDateTime.fromDateTime(dateTime: value!);
          widget.remindModel.remindDateTime = _remindDateTime;
        });
      },
      items: _weekDays,
    );
  }
}
