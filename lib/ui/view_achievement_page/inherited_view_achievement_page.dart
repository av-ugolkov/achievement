import 'package:achievement/data/model/achievement_model.dart';
import 'package:flutter/widgets.dart';

class InheritedViewAchievementPage extends InheritedWidget {
  final AchievementModel model;

  const InheritedViewAchievementPage({super.key, required this.model, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedViewAchievementPage oldWidget) {
    return oldWidget.model != model;
  }

  static AchievementModel of(BuildContext context) {
    var widget = context
        .dependOnInheritedWidgetOfExactType<InheritedViewAchievementPage>();
    if (widget != null) {
      return widget.model;
    }
    return AchievementModel.empty;
  }
}
