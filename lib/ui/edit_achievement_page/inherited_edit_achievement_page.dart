import 'package:achievement/ui/edit_achievement_page/edit_remind_card.dart';
import 'package:flutter/material.dart';

class InheritedEditAchievementPage extends InheritedWidget {
  final List<EditRemindCard> remindCards;

  InheritedEditAchievementPage({
    required this.remindCards,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedEditAchievementPage oldWidget) {
    return oldWidget.remindCards != remindCards;
  }
}
