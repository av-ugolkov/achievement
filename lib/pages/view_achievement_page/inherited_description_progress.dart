import 'package:achievement/model/progress_model.dart';
import 'package:flutter/material.dart';

class InheritedDescriptionProgress extends InheritedWidget {
  final Map<String, ProgressDescription> progressDescription;

  InheritedDescriptionProgress(
      {required this.progressDescription, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedDescriptionProgress oldWidget) {
    return oldWidget.progressDescription != progressDescription;
  }

  static Map<String, ProgressDescription> of(BuildContext context) {
    var widget = context
        .dependOnInheritedWidgetOfExactType<InheritedDescriptionProgress>();
    if (widget != null) {
      return widget.progressDescription;
    }
    return {};
  }
}
