import 'package:achievement/ui/view_achievement_page/inherited_view_achievement_page.dart';
import 'package:flutter/material.dart';

class DescriptionViewAchievement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var achievementModel = InheritedViewAchievementPage.of(context);

    if (achievementModel.description.isEmpty) {
      return Container();
    }

    return Text(
      achievementModel.description,
      style: TextStyle(fontSize: 18, color: Colors.black54),
    );
  }
}
