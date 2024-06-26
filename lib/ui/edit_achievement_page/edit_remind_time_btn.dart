import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/core/formate_date.dart';
import 'package:achievement/data/model/remind_model.dart';
import 'package:flutter/material.dart';

class EditRemindTimeBtn extends StatefulWidget {
  final ChangedDateTimeRange dateTimeRange;
  final RemindModel remindModel;
  final ValueChanged<DateTime>? onChangeTime;

  EditRemindTimeBtn({
    required this.remindModel,
    required this.dateTimeRange,
    this.onChangeTime,
  });

  @override
  _EditRemindTimeBtnState createState() => _EditRemindTimeBtnState();
}

class _EditRemindTimeBtnState extends State<EditRemindTimeBtn> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var newTimeOfDay = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
              widget.remindModel.remindDateTime.dateTime),
        );

        if (newTimeOfDay != null) {
          setState(() {
            widget.remindModel.remindDateTime.hour = newTimeOfDay.hour;
            widget.remindModel.remindDateTime.minute = newTimeOfDay.minute;
            widget.onChangeTime
                ?.call(widget.remindModel.remindDateTime.dateTime);
          });
        }
      },
      child: Text(
        FormateDate.hour24Minute(widget.remindModel.remindDateTime.dateTime),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
