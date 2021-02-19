import 'package:achievement/db/db_remind.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/utils/local_notification.dart';
import 'package:achievement/widgets/achievement_card.dart';
import 'package:flutter/material.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/generated/l10n.dart';

class AchievementPage extends StatefulWidget {
  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  @override
  void initState() {
    super.initState();
    LocalNotification.init(selectNotification: onSelectNotification);
  }

  Future<void> onSelectNotification(String payload) async {
    var achievements = await DbAchievement.db.getList();

    switch (payload) {
      case 'open':
        var index = int.tryParse(payload);
        openViewAchievementPage(achievements[index]);
        break;
      default:
        print('Ошибка команды');
    }
  }

  @override
  Widget build(BuildContext context) {
    var achievements = DbAchievement.db.getList();

    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).appName),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/create_achievement_page')
                .then((value) => setState(() {}));
          },
        ),
        body: FutureBuilder<List<AchievementModel>>(
          future: achievements,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length > 0) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      var achievement = snapshot.data[index];
                      return GestureDetector(
                          onTap: () {
                            openViewAchievementPage(achievement);
                          },
                          onLongPress: () {
                            setState(() {
                              deleteAchievement(achievement);
                            });
                          },
                          child: achievementCard(achievement));
                    });
              } else {
                return Container();
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }

  Future<void> deleteAchievement(AchievementModel achievement) async {
    for (var remindId in achievement.remindIds) {
      await DbRemind.db.delete(remindId);
    }
    var count = await DbAchievement.db.delete(achievement.id);
    print('delete achievement count: $count');
  }

  void openViewAchievementPage(AchievementModel model) {
    Navigator.pushNamed(context, '/view_achievement_page', arguments: model);
  }
}
