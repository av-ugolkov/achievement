import 'package:achievement/bridge/localization.dart';
import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/core/formate_date.dart';
import 'package:achievement/ui/edit_achievement_page/edit_remind_card/form_edit_remind_card.dart';
import 'package:achievement/ui/edit_achievement_page/number_picker_panel.dart';
import 'package:flutter/material.dart';

class EditDateTimeProgress extends StatefulWidget {
  final List<FormEditRemindCard> remindCards;
  final ChangedDateTimeRange dateRangeAchievement;

  EditDateTimeProgress({
    required this.remindCards,
    required this.dateRangeAchievement,
  });

  @override
  _EditDateTimeProgressState createState() => _EditDateTimeProgressState();
}

class _EditDateTimeProgressState extends State<EditDateTimeProgress> {
  bool get _hasRemind => widget.remindCards.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _rowDateTime(getLocaleOfContext(context).start_achiev,
            widget.dateRangeAchievement.start, () async {
          FocusScope.of(context).unfocus();
          var selectDate = await showDatePicker(
              context: context,
              initialDate: widget.dateRangeAchievement.start,
              firstDate: DateTime(0),
              lastDate: widget.dateRangeAchievement.end);
          setState(() {
            if (selectDate != null) {
              widget.dateRangeAchievement.start = selectDate;
              if (_hasRemind) {
                widget.remindCards.removeWhere((remind) {
                  var start = remind.remindModel.remindDateTime.dateTime
                      .compareTo(widget.dateRangeAchievement.start);
                  var end = remind.remindModel.remindDateTime.dateTime
                      .compareTo(widget.dateRangeAchievement.end);
                  return start < 0 || end > 0;
                });
              }
            }
          });
        }),
        _rowDateTime(
          getLocaleOfContext(context).finish_achiev,
          widget.dateRangeAchievement.end,
          () async {
            FocusScope.of(context).unfocus();
            var selectDate = await showDatePicker(
                context: context,
                initialDate: widget.dateRangeAchievement.end,
                firstDate: widget.dateRangeAchievement.start,
                lastDate: DateTime(9999));
            setState(() {
              if (selectDate != null) {
                widget.dateRangeAchievement.end = selectDate;
                if (_hasRemind) {
                  widget.remindCards.removeWhere((remind) {
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getLocaleOfContext(context).duration_achiev,
            ),
            NumberPickerPanel(
              delta: widget.dateRangeAchievement.end
                  .difference(widget.dateRangeAchievement.start)
                  .inDays,
              onEditComplete: (value) {
                setState(() {
                  widget.dateRangeAchievement.end = widget
                      .dateRangeAchievement.start
                      .add(Duration(days: value));
                });
              },
            )
          ],
        ),
      ],
    );
  }

  Widget _rowDateTime(String label, DateTime dateTime, void Function() func) {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
          ),
          TextButton(
            onPressed: func,
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(0),
            ),
            child: Text(
              FormateDate.yearMonthDay(dateTime),
            ),
          ),
        ],
      ),
    );
  }
}
