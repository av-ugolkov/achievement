import 'package:achievement/ui/achievements_page/inherited_achievement_page.dart';
import 'package:achievement/ui/achievements_page/achievement_card.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/core/local_notification.dart';
import 'package:achievement/data/model/achievement_model.dart';
import 'package:achievement/ui/common/loading_widgets.dart';
import 'package:flutter/material.dart';

class ListAchievement extends StatefulWidget {
  @override
  _ListAchievementState createState() => _ListAchievementState();
}

class _ListAchievementState extends State<ListAchievement> {
  @override
  Widget build(BuildContext context) {
    var state = InheritedAchievementPage.of(context);
    var futureAchievements =
        DbAchievement.db.getAchievementsByState(state: state);
    return FutureBuilder<List<AchievementModel>>(
      future: futureAchievements,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data!.isNotEmpty) {
            var achievements = <AchievementModel>[];
            if (state == AchievementState.active ||
                state == AchievementState.finished) {
              for (var item in snapshot.data!) {
                if (item.finishDate.isAfter(DateTime.now())) {
                  item.state = AchievementState.active;
                  DbAchievement.db.update(item);
                } else if (item.finishDate.isBefore(DateTime.now())) {
                  item.state = AchievementState.finished;
                  DbAchievement.db.update(item);
                }
                achievements.add(item);
              }
            } else {
              achievements.addAll(snapshot.data!);
            }

            return ListView.builder(
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  var achievement = achievements[index];
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
          }
          return Container();
        }
        return const Loading();
      },
    );
  }

  Future<void> _archivedAchievement(AchievementModel achievement) async {
    for (var remindId in achievement.remindIds) {
      await LocalNotification.cancelNotification(remindId);
    }
    achievement.state = AchievementState.archived;
    await DbAchievement.db.update(achievement);
  }

  void _openViewAchievementPage(AchievementModel model) async {
    var result = await Navigator.pushNamed(context, RouteViewAchievementPage,
        arguments: model);
    var newModel = result as AchievementModel;
    model.setModel(newModel);
    setState(() {});
  }
}
