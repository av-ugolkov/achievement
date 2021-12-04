import 'package:achievement/core/data_application.dart';
import 'package:achievement/core/notification/local_notification.dart';
import 'package:achievement/core/override_theme_data.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/ui/about_page/about_page.dart';
import 'package:achievement/ui/achievements_page/achievements_page.dart';
import 'package:achievement/ui/edit_achievement_page/edit_achievement_page.dart';
import 'package:achievement/ui/settings_page/settings_page.dart';
import 'package:achievement/ui/view_achievement_page/view_achievement_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:achievement/generated/l10n.dart';
import 'package:achievement/core/utils.dart' as utils;
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  void startApp() async {
    var docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;

    await Firebase.initializeApp(
      name: 'com.ugolkov.achievement',
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBzrHcu4TQK8Ji31Bnyr8faDQwEanONPDE',
        appId: '1:1087083017957:android:160daff30995acc3d1460c',
        messagingSenderId: '1087083017957',
        projectId: 'achievement-dc79f',
      ),
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(MyApp());
  }

  DataApplication();

  LocalNotification.init();
  startApp();
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

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
        RouteEditAchievementPage: (context) => EditAchievementPage(),
        RouteViewAchievementPage: (context) => ViewAchievementPage(),
        RouteSettingsPage: (context) => SettingsPage(),
        RouteAboutPage: (context) => AboutPage()
      },
      navigatorObservers: <NavigatorObserver>[observer],
      theme: buildThemeLight(),
      darkTheme: buildThemeDark(),
      home: AchievementsPage(),
    );
  }
}
