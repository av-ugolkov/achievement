import 'package:achievement/db/db_file.dart';
import 'package:sqflite/sqflite.dart';

class DbBlockSession {
  DbBlockSession._();
  static final DbBlockSession db = DbBlockSession._();

  final String _table = 'BlockSessionDB';

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'session_date TEXT NOT NULL UNIQUE, '
      'unlocked INTEGER NOT NULL DEFAULT 0, '
      'unlock_time INTEGER)',
    );
  }

  Future<bool> isUnlockedToday() async {
    final today = _today();
    final rows = await DbFile.db.query(_table,
        where: 'session_date = ?', whereArgs: [today]);
    if (rows.isEmpty) return false;
    return (rows.first['unlocked'] as int) == 1;
  }

  Future<void> markUnlocked() async {
    final today = _today();
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = await DbFile.db.query(_table,
        where: 'session_date = ?', whereArgs: [today]);
    if (rows.isEmpty) {
      await DbFile.db.insert(_table, {
        'session_date': today,
        'unlocked': 1,
        'unlock_time': now,
      });
    } else {
      await DbFile.db.update(
        _table,
        {'unlocked': 1, 'unlock_time': now},
        where: 'session_date = ?',
        whereArgs: [today],
      );
    }
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
