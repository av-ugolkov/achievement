import 'package:achievement/ui/view_achievement_page/description_view_achievement.dart';
import 'package:achievement/ui/view_achievement_page/fab/floating_action_button.dart';
import 'package:achievement/bridge/localization.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/ui/view_achievement_page/description_progress.dart';
import 'package:achievement/ui/view_achievement_page/inherited_view_achievement_page.dart';
import 'package:achievement/ui/view_achievement_page/reminds_view_achievement.dart';
import 'package:achievement/ui/view_achievement_page/title_view_achievement.dart';
import 'package:flutter/material.dart';

class ViewAchievementPage extends StatefulWidget {
  @override
  _ViewAchievementPageState createState() => _ViewAchievementPageState();
}

class _ViewAchievementPageState extends State<ViewAchievementPage> {
  @override
  Widget build(BuildContext context) {
    var settings = ModalRoute.of(context)?.settings;
    var achievementModel = settings!.arguments as AchievementModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(getLocaleOfContext(context).view_achievement_title),
      ),
      floatingActionButton: FAB(
          model: achievementModel,
          onUpdateModel: () {
            setState(() {});
          }),
      body: InheritedViewAchievementPage(
        model: achievementModel,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            TitleViewAchievement(),
            SizedBox(height: 3),
            DescriptionViewAchievement(),
            SizedBox(height: 3),
            DescriptionProgress(),
            SizedBox(height: 3),
            RemindsViewAchievement(),
          ],
        ),
      ),
    );
  }
}
