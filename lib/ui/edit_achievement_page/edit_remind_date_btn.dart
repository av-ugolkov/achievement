import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/core/formate_date.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:flutter/material.dart';

class EditRemindDateBtn extends StatefulWidget {
  final ChangedDateTimeRange dateTimeRange;
  final RemindModel remindModel;

  EditRemindDateBtn({
    required this.remindModel,
    required this.dateTimeRange,
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
            widget.remindModel.remindDateTime =
                RemindDateTime.fromDateTime(dateTime: remindDate);
          });
        }
      },
      child: Text(
        FormateDate.yearNumMonthDay(widget.remindModel.remindDateTime.dateTime),
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
}
