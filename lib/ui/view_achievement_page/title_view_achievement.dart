import 'dart:io';
import 'package:achievement/ui/view_achievement_page/inherited_view_achievement_page.dart';
import 'package:flutter/material.dart';

class TitleViewAchievement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var achievementModel = InheritedViewAchievementPage.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 75,
          height: 75,
          child: achievementModel.imagePath.isEmpty
              ? Icon(
                  Icons.not_interested,
                  color: Colors.grey[300],
                  size: 75,
                )
              : Image.file(
                  File(achievementModel.imagePath),
                ),
        ),
        SizedBox(width: 4),
        DecoratedBox(
          decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.black, width: 2))),
          child: Text(
            achievementModel.header,
            maxLines: 2,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
