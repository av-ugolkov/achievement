import 'package:achievement/core/enums.dart';
import 'package:achievement/core/formate_date.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/data/model/remind_model.dart';
import 'package:achievement/ui/view_achievement_page/inherited_view_achievement_page.dart';
import 'package:flutter/material.dart';

class RemindsViewAchievement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var achievementModel = InheritedViewAchievementPage.of(context);

    if (achievementModel.remindIds.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        Container(
          child: (achievementModel.remindIds.isEmpty)
              ? null
              : _remindWidget(achievementModel.remindIds),
        )
      ],
    );
  }

  Widget _remindWidget(List<int> ids) {
    var reminds = DbRemind.db.getReminds(ids);
    return FutureBuilder(
      future: reminds,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var reminds = snapshot.data as List<RemindModel>;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reminds.map((value) {
                return _remindCard(value);
              }).toList());
        } else {
          return Container();
        }
      },
    );
  }

  Widget _remindCard(RemindModel model) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.alarm),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(_getStringRepition(model)),
              const Text(' в '),
              Text(model.remindDateTime.time),
            ],
          )
        ],
      ),
    );
  }

  String _getStringRepition(RemindModel model) {
    switch (model.typeRepition) {
      case TypeRepition.day:
        return 'каждый день';
      case TypeRepition.week:
        return 'каждую неделю ${FormateDate.weekDayName(model.remindDateTime.dateTime)}';
      case TypeRepition.month:
        return 'каждый месяц ${model.remindDateTime.day} числа';
      default:
        return model.remindDateTime.date;
    }
  }
}
