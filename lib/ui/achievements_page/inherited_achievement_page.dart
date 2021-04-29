import '/core/enums.dart';
import 'package:flutter/material.dart';

class InheritedAchievementPage extends InheritedWidget {
  final AchievementState state;

  InheritedAchievementPage({required this.state, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedAchievementPage oldWidget) {
    return oldWidget.state != state;
  }

  static AchievementState of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<InheritedAchievementPage>()
          ?.state ??
      AchievementState.active;
}
