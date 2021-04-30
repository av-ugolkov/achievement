import '/ui/edit_achievement_page/remind_day.dart';
import '/core/changed_date_time_range.dart';
import '/core/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_components/components/date_time_progress/date_time_progress.dart';

class EditDateTimeProgress extends StatefulWidget {
  final List<RemindDay> remindDays;
  final ChangedDateTimeRange dateRangeAchievement;

  EditDateTimeProgress({
    required this.remindDays,
    required this.dateRangeAchievement,
  });

  @override
  _EditDateTimeProgressState createState() => _EditDateTimeProgressState();
}

class _EditDateTimeProgressState extends State<EditDateTimeProgress> {
  bool get _hasRemind => widget.remindDays.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return DateTimeProgress(
      start: widget.dateRangeAchievement.start,
      finish: widget.dateRangeAchievement.end,
      current: DateTime.now().getDate(),
      onChangeStart: (dateTime) async {
        FocusScope.of(context).unfocus();
        var selectDate = await showDatePicker(
            context: context,
            initialDate: dateTime,
            firstDate: DateTime(0),
            lastDate: widget.dateRangeAchievement.end);
        setState(() {
          if (selectDate != null) {
            widget.dateRangeAchievement.start = selectDate;
            if (_hasRemind) {
              widget.remindDays.removeWhere((remind) {
                var start = remind.remindModel.remindDateTime.dateTime
                    .compareTo(widget.dateRangeAchievement.start);
                var end = remind.remindModel.remindDateTime.dateTime
                    .compareTo(widget.dateRangeAchievement.end);
                return start < 0 || end > 0;
              });
            }
          }
        });
      },
      onChangeFinish: (dateTime) async {
        FocusScope.of(context).unfocus();
        var selectDate = await showDatePicker(
            context: context,
            initialDate: dateTime,
            firstDate: widget.dateRangeAchievement.start,
            lastDate: DateTime(9999));
        setState(() {
          if (selectDate != null) {
            widget.dateRangeAchievement.end = selectDate;
            if (_hasRemind) {
              widget.remindDays.removeWhere((remind) {
                var start = remind.remindModel.remindDateTime.dateTime
                    .compareTo(widget.dateRangeAchievement.start);
                var end = remind.remindModel.remindDateTime.dateTime
                    .compareTo(widget.dateRangeAchievement.end);
                return start < 0 || end > 0;
              });
            }
          }
        });
      },
    );
  }
}
