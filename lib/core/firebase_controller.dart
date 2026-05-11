import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseController {
  static Future<void> init() async {
    if (kDebugMode) {
      await Future.sync(() => log('fake init firebase'));
    } else {
      await Firebase.initializeApp();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }
  }

  static FirebaseAnalyticsObserver createObserver() {
    var analytics = FirebaseAnalytics.instance;
    var observer = FirebaseAnalyticsObserver(analytics: analytics);
    return observer;
  }
}
