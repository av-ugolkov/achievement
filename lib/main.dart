import 'package:achievement/pages/create_achievement_page.dart';
import 'package:flutter/material.dart';
import 'pages/achievement_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Achievement',
      initialRoute: '/',
      routes: {
        '/create_achievement_page': (context) => CreateAchievementPage()
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AchievementPaage(),
    );
  }
}
