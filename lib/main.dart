import 'package:achievement/core/data_application.dart';
import 'package:achievement/core/firebase_controller.dart';
import 'package:achievement/core/notification/local_notification.dart';
import 'package:achievement/core/override_theme_data.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/core/services/background_watch_service.dart';
import 'package:achievement/ui/about_page/about_page.dart';
import 'package:achievement/ui/achievements_page/achievements_page.dart';
import 'package:achievement/ui/blocker_page/blocker_page.dart';
import 'package:achievement/ui/edit_achievement_page/edit_achievement_page.dart';
import 'package:achievement/ui/settings_page/settings_page.dart';
import 'package:achievement/ui/app_picker_page/app_picker_page.dart';
import 'package:achievement/ui/condition_config_page/condition_config_page.dart';
import 'package:achievement/ui/unlock_success_page/unlock_success_page.dart';
import 'package:achievement/ui/view_achievement_page/view_achievement_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:achievement/generated/l10n.dart';
import 'package:achievement/core/utils.dart' as utils;
import 'package:workmanager/workmanager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const _blockerChannel = MethodChannel('com.ugolkov.achievement/blocker');

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  void startApp() async {
    var docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;

    await FirebaseController.init();

    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      kWatchTaskUniqueName,
      kWatchTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );

    runApp(const MyApp());

    // Check if app was launched from the accessibility service blocker intent
    final pendingPackage = await _blockerChannel
        .invokeMethod<String>('getPendingBlockedPackage');
    if (pendingPackage != null && pendingPackage.isNotEmpty) {
      navigatorKey.currentState
          ?.pushNamed('/blocker', arguments: pendingPackage);
    }

    // Listen for blocker events while app is running
    _blockerChannel.setMethodCallHandler((call) async {
      if (call.method == 'showBlocker') {
        navigatorKey.currentState
            ?.pushNamed('/blocker', arguments: call.arguments as String);
      }
    });
  }

  DataApplication();
  LocalNotification.init();
  startApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      locale: const Locale('ru'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'Achievement',
      initialRoute: '/',
      routes: {
        routeEditAchievementPage: (context) => EditAchievementPage(),
        routeViewAchievementPage: (context) => ViewAchievementPage(),
        routeSettingsPage: (context) => SettingsPage(),
        routeAboutPage: (context) => AboutPage(),
        '/blocker': (context) => const BlockerPage(),
        routeAppPickerPage: (context) => const AppPickerPage(),
        routeConditionConfigPage: (context) => const ConditionConfigPage(),
        routeUnlockSuccessPage: (context) => const UnlockSuccessPage(),
      },
      navigatorObservers: <NavigatorObserver>[
        if (kReleaseMode) FirebaseController.createObserver()
      ],
      theme: buildThemeLight(),
      darkTheme: buildThemeDark(),
      home: AchievementsPage(),
    );
  }
}
