import 'dart:developer';

import 'package:flutter/material.dart';

class OverrideThemeData {
  OverrideThemeData._();

  static final OverrideThemeData _inst = OverrideThemeData._();

  static OverrideThemeData of() {
    return _inst;
  }

  ThemeData _themeData = ThemeData.light();
  ThemeData get themeData => _themeData;
  bool _dark = false;
  bool get dark => _dark;
  set dark(bool value) {
    _dark = value;
    _themeData = _dark ? ThemeData.dark() : ThemeData.light();
    log(_dark.toString());
  }

  ThemeData buildTheme() {
    _themeData = _dark ? ThemeData.dark() : ThemeData.light();
    return _themeData;
    return _themeData.copyWith(
      colorScheme: _shrineColorScheme,
      accentColor: shrineBrown900,
      primaryColor: shrinePink100,
      buttonColor: shrinePink100,
      scaffoldBackgroundColor: shrineBackgroundWhite,
      cardColor: shrineBackgroundWhite,
      textSelectionTheme: TextSelectionThemeData(selectionColor: shrinePink100),
      errorColor: shrineErrorRed,
      buttonTheme: const ButtonThemeData(
        colorScheme: _shrineColorScheme,
        textTheme: ButtonTextTheme.normal,
      ),
      primaryIconTheme: _customIconTheme(_themeData.iconTheme),
      textTheme: _buildShrineTextTheme(_themeData.textTheme),
      primaryTextTheme: _buildShrineTextTheme(_themeData.primaryTextTheme),
      accentTextTheme: _buildShrineTextTheme(_themeData.accentTextTheme),
      iconTheme: _customIconTheme(_themeData.iconTheme),
    );
  }

  static IconThemeData _customIconTheme(IconThemeData original) {
    return original.copyWith(color: shrineBrown900);
  }

  static TextTheme _buildShrineTextTheme(TextTheme base) {
    return base
        .copyWith(
          caption: base.caption?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          button: base.button?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        )
        .apply(
          fontFamily: 'Rubik',
          displayColor: shrineBrown900,
          bodyColor: shrineBrown900,
        );
  }

  static const ColorScheme _shrineColorScheme = ColorScheme(
    primary: shrinePink100,
    primaryVariant: shrineBrown900,
    secondary: shrinePink50,
    secondaryVariant: shrineBrown900,
    surface: shrineSurfaceWhite,
    background: shrineBackgroundWhite,
    error: shrineErrorRed,
    onPrimary: shrineBrown900,
    onSecondary: shrineBrown900,
    onSurface: shrineBrown900,
    onBackground: shrineBrown900,
    onError: shrineSurfaceWhite,
    brightness: Brightness.light,
  );

  static const Color shrinePink50 = Color(0xFFFEEAE6);
  static const Color shrinePink100 = Color(0xFFFEDBD0);
  static const Color shrinePink300 = Color(0xFFFBB8AC);
  static const Color shrinePink400 = Color(0xFFEAA4A4);

  static const Color shrineBrown900 = Color(0xFF442B2D);
  static const Color shrineBrown600 = Color(0xFF7D4F52);

  static const Color shrineErrorRed = Color(0xFFC5032B);

  static const Color shrineSurfaceWhite = Color(0xFFFFFBFA);
  static const Color shrineBackgroundWhite = Colors.white;
}
