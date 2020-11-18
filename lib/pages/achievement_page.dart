import 'package:achievement/db/db_remind.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/widgets/achievement_card.dart';
import 'package:flutter/material.dart';
import 'package:achievement/db/db_achievement.dart';

class AchievementPage extends StatefulWidget {
  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  @override
  Widget build(BuildContext context) {
    var achievements = DbAchievement.db.getList();

    return Scaffold(
        appBar: AppBar(
          title: Text('Достигатор'),
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
                            Navigator.pushNamed(
                                context, '/view_achievement_page',
                                arguments: achievement);
                          },
                          onLongPress: () {
                            setState(() async {
                              if (achievement.remind != null) {
                                await DbRemind.db.delete(achievement.remind.id);
                              }
                              var id =
                                  await DbAchievement.db.delete(achievement.id);
                              print('delete achievement $id');
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
}
