import 'package:flutter/widgets.dart';

extension ContextExt on BuildContext {
  static const _spSw600 = .6;

  double get scHeight => MediaQuery.of(this).size.height;
  double get scWidth => MediaQuery.of(this).size.width;
  bool get sw600 => scWidth <= 600.0;

  TextStyle sp(TextStyle style) =>
      style.copyWith(fontSize: sw600 ? style.fontSize! * _spSw600 : null);
}

extension ExtensionDateTime on DateTime {
  DateTime getDate() {
    return DateTime(year, month, day);
  }
}
