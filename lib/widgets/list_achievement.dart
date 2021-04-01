import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/utils/local_notification.dart';
import 'package:achievement/widgets/achievement_card.dart';
import 'package:flutter/material.dart';

class ListAchievement extends StatefulWidget {
  @override
  _ListAchievementState createState() => _ListAchievementState();
}

class _ListAchievementState extends State<ListAchievement> {
  @override
  Widget build(BuildContext context) {
    var achievements = DbAchievement.db.getList();

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
                      key: Key(achievement.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                          child: Icon(Icons.archive)),
                      onDismissed: (direction) async {
                        await _deleteAchievement(achievement);
                      },
                      child: achievementCard(achievement),
                    ),
                  );
                });
          } else {
            return Container();
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<void> _deleteAchievement(AchievementModel achievement) async {
    for (var remindId in achievement.remindIds) {
      await LocalNotification.cancelNotification(remindId);
      await DbRemind.db.delete(remindId);
    }
    var count = await DbAchievement.db.delete(achievement.id);
    print('delete achievement count: $count');
  }

  void _openViewAchievementPage(AchievementModel model) {
    Navigator.pushNamed(context, '/view_achievement_page', arguments: model);
  }
}
