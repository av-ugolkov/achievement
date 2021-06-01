import 'package:achievement/ui/view_achievement_page/inherited_view_achievement_page.dart';
import 'package:flutter/material.dart';

class DescriptionViewAchievement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var achievementModel = InheritedViewAchievementPage.of(context);
    var descController =
        TextEditingController(text: achievementModel.description);

    return TextField(
      enabled: false,
      controller: descController,
      style: TextStyle(fontSize: 18, color: Colors.black87),
      decoration: InputDecoration(
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: descController.text.isNotEmpty ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}
