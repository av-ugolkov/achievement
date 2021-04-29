import '/core/page_routes.dart';
import '/ui/achievements_page/achievements_page.dart';
import '/ui/edit_achievement_page/edit_achievement_page.dart';
import '/ui/splash_page/splash_page.dart';
import '/ui/view_achievement_page/view_achievement_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import '/generated/l10n.dart';
import '/core/utils.dart' as utils;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  void startApp() async {
    var docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;

    runApp(MyApp());
  }

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
        RouteAchievementPage: (context) => AchievementsPage(),
        RouteEditeAchievementPage: (context) => EditAchievementPage(),
        RouteViewAchievementPage: (context) => ViewAchievementPage()
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(),
    );
  }
}
