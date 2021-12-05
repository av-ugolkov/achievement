import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseController {
  static void init() async {
    if (kDebugMode) {
      await Future.sync(() => log('init firebase'));
    } else {
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
    }
  }

  static FirebaseAnalyticsObserver createObserver() {
    var analytics = FirebaseAnalytics();
    var observer = FirebaseAnalyticsObserver(analytics: analytics);
    return observer;
  }
}
