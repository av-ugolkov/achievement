import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/core/formate_date.dart';
import 'package:achievement/data/model/remind_model.dart';
import 'package:flutter/material.dart';

class EditRemindDateBtn extends StatefulWidget {
  final ChangedDateTimeRange dateTimeRange;
  final RemindModel remindModel;
  final ValueChanged<DateTime>? onChangeDate;

  EditRemindDateBtn({
    required this.remindModel,
    required this.dateTimeRange,
    this.onChangeDate,
  });

  @override
  _EditRemindDateBtnState createState() => _EditRemindDateBtnState();
}

class _EditRemindDateBtnState extends State<EditRemindDateBtn> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var remindDate = await showDatePicker(
            context: context,
            initialDate: widget.remindModel.remindDateTime.dateTime,
            firstDate: widget.dateTimeRange.start,
            lastDate: widget.dateTimeRange.end);

        if (remindDate != null) {
          setState(() {
            widget.remindModel.remindDateTime.year = remindDate.year;
            widget.remindModel.remindDateTime.month = remindDate.month;
            widget.remindModel.remindDateTime.day = remindDate.day;
            widget.onChangeDate
                ?.call(widget.remindModel.remindDateTime.dateTime);
          });
        }
      },
      child: Text(
        FormateDate.yearNumMonthDay(widget.remindModel.remindDateTime.dateTime),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
