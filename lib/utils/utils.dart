import 'dart:io';
import 'package:flutter/material.dart';

late Directory docsDir;

const _spSw600 = .6;

extension ContextExt on BuildContext {
  double get scHeight => MediaQuery.of(this).size.height;
  double get scWidth => MediaQuery.of(this).size.width;
  bool get sw600 => scWidth <= 600.0;

  TextStyle sp(TextStyle style) =>
      style.copyWith(fontSize: sw600 ? style.fontSize! * _spSw600 : null);
}
