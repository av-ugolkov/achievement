import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:achievement/core/services/block_sync_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('writeBlockList stores JSON-encoded list', () async {
    final svc = BlockSyncService();
    await svc.writeBlockList(['com.google.android.youtube', 'com.facebook.katana']);
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('block_list');
    expect(jsonDecode(stored!), ['com.google.android.youtube', 'com.facebook.katana']);
  });

  test('writeThreshold stores int', () async {
    final svc = BlockSyncService();
    await svc.writeThreshold(30);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('threshold_minutes'), 30);
  });

  test('readThreshold returns default 60 when unset', () async {
    final svc = BlockSyncService();
    expect(await svc.readThreshold(), 60);
  });

  test('writeAchievementUsage and readAchievementUsage round-trip', () async {
    final svc = BlockSyncService();
    await svc.writeAchievementUsage(45);
    expect(await svc.readAchievementUsage(), 45);
  });
}
