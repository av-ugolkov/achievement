import 'dart:io';
import 'package:achievement/pages/create_edit_achievement_page.dart';
import 'package:achievement/pages/splash_page.dart';
import 'package:achievement/pages/view_achievement_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'pages/achievement_page.dart';
import 'utils/utils.dart' as utils;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  startApp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;

    runApp(MyApp());
  }

  startApp();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Achievement',
      initialRoute: '/',
      routes: {
        '/achievement_page': (context) => AchievementPage(),
        '/create_achievement_page': (context) => CreateEditAchievementPage(),
        '/view_achievement_page': (context) => ViewAchievementPage()
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(),
    );
  }
}
