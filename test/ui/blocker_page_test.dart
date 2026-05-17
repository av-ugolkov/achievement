import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:achievement/ui/blocker_page/blocker_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'threshold_minutes': 60,
      'achievement_usage_minutes': 20,
    });
  });

  testWidgets('shows lock icon and blocked package name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            settings: RouteSettings(
              name: '/blocker',
              arguments: 'com.google.android.youtube',
            ),
            builder: (_) => const BlockerPage(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.text('com.google.android.youtube'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('На главную'), findsOneWidget);
  });
}
