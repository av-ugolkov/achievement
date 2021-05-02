import 'package:achievement/ui/achievements_page/inherited_achievement_page.dart';
import 'package:achievement/ui/achievements_page/achievement_card.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/core/local_notification.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:flutter/material.dart';

class ListAchievement extends StatefulWidget {
  @override
  _ListAchievementState createState() => _ListAchievementState();
}

class _ListAchievementState extends State<ListAchievement> {
  @override
  Widget build(BuildContext context) {
    var state = InheritedAchievementPage.of(context);
    var achievements = DbAchievement.db.getAchievementsByState(state: state);
    return FutureBuilder<List<AchievementModel>>(
      future: achievements,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var achievement = snapshot.data![index];
                  return GestureDetector(
                    onTap: () {
                      _openViewAchievementPage(achievement);
                    },
                    child: Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                          child: Icon(Icons.archive)),
                      onDismissed: (direction) async {
                        await _archivedAchievement(achievement);
                      },
                      child: AchievementCard(achievement: achievement),
                    ),
                  );
                });
          } else {
            return Container();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> _archivedAchievement(AchievementModel achievement) async {
    for (var remindId in achievement.remindIds) {
      await LocalNotification.cancelNotification(remindId);
      await DbRemind.db.delete(remindId);
    }
    achievement.state = AchievementState.archived;
    await DbAchievement.db.update(achievement);
  }

  void _openViewAchievementPage(AchievementModel model) {
    Navigator.pushNamed(context, RouteViewAchievementPage, arguments: model);
  }
}
