import 'package:achievement/bridge/localization.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getLocaleOfContext(context).settings),
      ),
      body: Row(
        children: [],
      ),
    );
  }
}
