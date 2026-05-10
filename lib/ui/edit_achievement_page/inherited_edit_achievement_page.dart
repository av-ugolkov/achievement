import 'package:achievement/ui/edit_achievement_page/edit_remind_card/edit_remind_card.dart';
import 'package:flutter/material.dart';

class InheritedEditAchievementPage extends InheritedWidget {
  final List<EditRemindCard> remindCards;

  const InheritedEditAchievementPage({super.key,
    required this.remindCards,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedEditAchievementPage oldWidget) {
    return oldWidget.remindCards != remindCards;
  }
}
