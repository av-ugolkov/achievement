import 'package:achievement/core/override_theme_data.dart';
import 'package:flutter/material.dart';

class DarkMode extends StatefulWidget {
  const DarkMode({Key? key}) : super(key: key);

  @override
  _DarkModeState createState() => _DarkModeState();
}

class _DarkModeState extends State<DarkMode> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text('Темный режим'),
          Switch(
              value: OverrideThemeData.of().dark,
              onChanged: (value) {
                setState(() {
                  OverrideThemeData.of().dark = value;
                });
              }),
        ],
      ),
    );
  }
}
