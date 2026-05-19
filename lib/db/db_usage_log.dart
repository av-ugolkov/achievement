import 'package:achievement/db/db_file.dart';
import 'package:sqflite/sqflite.dart';

class DbUsageLog {
  DbUsageLog._();
  static final DbUsageLog db = DbUsageLog._();

  final String _table = 'UsageLogDB';

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'package_name TEXT NOT NULL, '
      'log_date TEXT NOT NULL, '
      'minutes INTEGER NOT NULL, '
      'recorded_at INTEGER NOT NULL)',
    );
  }

  Future<void> insertSnapshot({
    required String packageName,
    required String logDate,
    required int minutes,
  }) async {
    await DbFile.db.insert(_table, {
      'package_name': packageName,
      'log_date': logDate,
      'minutes': minutes,
      'recorded_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
