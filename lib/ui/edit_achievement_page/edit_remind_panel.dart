import 'package:achievement/bridge/localization.dart';
import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/ui/edit_achievement_page/edit_remind_card.dart';
import 'package:flutter/material.dart';

class EditRemindPanel extends StatefulWidget {
  final List<EditRemindCard> remindCards;
  final ChangedDateTimeRange dateRangeAchievement;

  EditRemindPanel({
    required this.remindCards,
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
                  if (widget.remindCards.isEmpty) {
                    var remindDateTime = RemindDateTime.fromDateTime(
                      dateTime: DateTime.now().add(
                        Duration(hours: 12),
                      ),
                    );
                    var remindModel = RemindModel(
                        id: -1,
                        typeRepition: TypeRepition.none,
                        remindDateTime: remindDateTime);
                    var newRemindCard = EditRemindCard(
                      remindModel: remindModel,
                      dateTimeRange: widget.dateRangeAchievement,
                    );
                    widget.remindCards.add(newRemindCard);
                  } else {
                    var reCreateRemindCard = <EditRemindCard>[];
                    for (var remindCard in widget.remindCards) {
                      var newRemindDay = EditRemindCard(
                        remindModel: remindCard.remindModel,
                        dateTimeRange: widget.dateRangeAchievement,
                      );
                      reCreateRemindCard.add(newRemindDay);
                    }
                    widget.remindCards.clear();
                    widget.remindCards.addAll(reCreateRemindCard);
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
    var cards = widget.remindCards.map((card) {
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
                    dateTime: DateTime.now().add(
                      Duration(hours: 12),
                    ),
                  );
                  var remindModel = RemindModel(
                      id: -1,
                      typeRepition: TypeRepition.none,
                      remindDateTime: remindDateTime);
                  var newRemindCard = EditRemindCard(
                    remindModel: remindModel,
                    dateTimeRange: widget.dateRangeAchievement,
                  );
                  widget.remindCards.add(newRemindCard);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _removeCustomDay(EditRemindCard remindCard) {
    setState(() {
      widget.remindCards.remove(remindCard);
      if (widget.remindCards.isEmpty) {
        _isRemind = false;
      }
    });
  }
}
