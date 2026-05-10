import 'package:achievement/core/enums.dart';
import 'package:flutter/material.dart';

class InheritedAchievementPage extends InheritedWidget {
  final AchievementState state;

  const InheritedAchievementPage({super.key, required this.state, required super.child});

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
