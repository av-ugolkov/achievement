import 'package:achievement/core/notification/local_notification.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/ui/achievements_page/achievements_page.dart';
import 'package:achievement/ui/edit_achievement_page/edit_achievement_page.dart';
import 'package:achievement/ui/view_achievement_page/view_achievement_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:achievement/generated/l10n.dart';
import 'package:achievement/core/utils.dart' as utils;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  void startApp() async {
    var docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;

    runApp(MyApp());
  }

  LocalNotification.init();
  startApp();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('ru'),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'Achievement',
      initialRoute: '/',
      routes: {
        RouteEditeAchievementPage: (context) => EditAchievementPage(),
        RouteViewAchievementPage: (context) => ViewAchievementPage()
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AchievementsPage(),
    );
  }
}
