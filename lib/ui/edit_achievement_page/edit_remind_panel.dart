import 'package:achievement/bridge/localization.dart';
import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/ui/edit_achievement_page/remind_day.dart';
import 'package:flutter/material.dart';

class EditRemindPanel extends StatefulWidget {
  final List<RemindDay> remindDays;
  final ChangedDateTimeRange dateRangeAchievement;

  EditRemindPanel({
    required this.remindDays,
    required this.dateRangeAchievement,
  });

  @override
  _EditRemindPanelState createState() => _EditRemindPanelState();
}

class _EditRemindPanelState extends State<EditRemindPanel> {
  bool _isRemind = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getLocaleOfContext(context).remind,
              style: TextStyle(fontSize: 14),
            ),
            Switch(
              value: _isRemind,
              onChanged: (value) {
                setState(() {
                  FocusScope.of(context).unfocus();
                  _isRemind = value;
                  if (!_isRemind) {
                    return;
                  }
                  if (widget.remindDays.isEmpty) {
                    var remindDateTime = RemindDateTime.fromDateTime(
                      dateTime: widget.dateRangeAchievement.start.add(
                        Duration(hours: 12),
                      ),
                    );
                    var remindModel = RemindModel(
                        id: -1,
                        typeRepition: TypeRepition.none,
                        remindDateTime: remindDateTime);
                    var newRemindDay = RemindDay(
                      remindModel: remindModel,
                      dateTimeRange: widget.dateRangeAchievement,
                    );
                    widget.remindDays.add(newRemindDay);
                  } else {
                    var reCreateRemindDays = <RemindDay>[];
                    for (var remindDay in widget.remindDays) {
                      var newRemindDay = RemindDay(
                        remindModel: remindDay.remindModel,
                        dateTimeRange: widget.dateRangeAchievement,
                      );
                      reCreateRemindDays.add(newRemindDay);
                    }
                    widget.remindDays.clear();
                    widget.remindDays.addAll(reCreateRemindDays);
                  }
                });
              },
            )
          ],
        ),
        Container(
          child: _isRemind ? _remindsPanel() : null,
        )
      ],
    );
  }

  Widget _remindsPanel() {
    var cards = widget.remindDays.map((card) {
      return Dismissible(
        key: Key(card.hashCode.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          child: Container(
            width: 70,
            child: Icon(
              Icons.delete,
            ),
          ),
        ),
        onDismissed: (direction) {
          _removeCustomDay(card);
        },
        child: card,
      );
    }).toList();
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: cards,
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle_outlined,
              size: 32,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(
                () {
                  var remindDateTime = RemindDateTime.fromDateTime(
                    dateTime: widget.dateRangeAchievement.start.add(
                      Duration(hours: 12),
                    ),
                  );
                  var remindModel = RemindModel(
                      id: -1,
                      typeRepition: TypeRepition.none,
                      remindDateTime: remindDateTime);
                  var newRemindDay = RemindDay(
                    remindModel: remindModel,
                    dateTimeRange: widget.dateRangeAchievement,
                  );
                  widget.remindDays.add(newRemindDay);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _removeCustomDay(RemindDay remindCustomDay) {
    setState(() {
      widget.remindDays.remove(remindCustomDay);
      if (widget.remindDays.isEmpty) {
        _isRemind = false;
      }
    });
  }
}
