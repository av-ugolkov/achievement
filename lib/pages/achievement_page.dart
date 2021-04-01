import 'dart:developer';

import 'package:achievement/bridge/localization.dart';
import 'package:achievement/utils/local_notification.dart';
import 'package:achievement/widgets/list_achievement.dart';
import 'package:flutter/material.dart';

class AchievementPage extends StatefulWidget {
  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  @override
  void initState() {
    super.initState();
    LocalNotification.init(onSelectNotification);
  }

  Future<void> onSelectNotification(String? payload) async {
    //var achievements = await DbAchievement.db.getList();
    switch (payload) {
      case 'open':
        log('Нужна обработка открытия ачивки');
        //var index = int.tryParse(payload);
        //openViewAchievementPage(achievements[index]);
        break;
      default:
        log('Error open achievement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getLocaleOfContext(context).appName),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_achievement_page')
              .then((value) => setState(() {}));
        },
        child: Icon(Icons.add),
      ),
      body: ListAchievement(),
    );
  }
}
