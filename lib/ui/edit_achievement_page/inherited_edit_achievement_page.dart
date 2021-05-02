import 'package:achievement/ui/edit_achievement_page/remind_card.dart';
import 'package:flutter/material.dart';

class InheritedEditAchievementPage extends InheritedWidget {
  final List<RemindCard> remindDays;

  InheritedEditAchievementPage({
    required this.remindDays,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedEditAchievementPage oldWidget) {
    return oldWidget.remindDays != remindDays;
  }
}
