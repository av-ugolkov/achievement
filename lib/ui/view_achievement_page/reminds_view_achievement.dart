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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: _remindWidget(achievementModel.remindIds),
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
              Text(
                  '${FormateDate.hour24Minute(model.remindDateTime.dateTime)}'),
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
      default:
        return model.remindDateTime.date;
    }
  }
}
