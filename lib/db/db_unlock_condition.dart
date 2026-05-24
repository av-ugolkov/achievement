import 'package:sqflite/sqflite.dart';
import 'db_file.dart';
import 'package:achievement/data/model/unlock_condition_model.dart';

class DbUnlockCondition {
  DbUnlockCondition._();
  static final DbUnlockCondition db = DbUnlockCondition._();

  final String _table = 'UnlockConditionDB';

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'condition_type INTEGER NOT NULL DEFAULT 0, '
      'target_package TEXT NOT NULL, '
      'target_app_name TEXT NOT NULL, '
      'threshold_mins INTEGER NOT NULL DEFAULT 60, '
      'is_active INTEGER NOT NULL DEFAULT 1)',
    );
  }

  Future<UnlockConditionModel?> getActive() async {
    final rows = await DbFile.db.query(_table,
        where: 'is_active = ?', whereArgs: [1], limit: 1);
    if (rows.isEmpty) return null;
    return UnlockConditionModel.fromMap(rows.first);
  }

  Future<void> upsert(UnlockConditionModel model) async {
    await DbFile.db.update(_table, {'is_active': 0});
    final map = model.toMap()..remove('id');
    await DbFile.db.insert(_table, map);
  }

  Future<void> clearActive() async {
    await DbFile.db.update(_table, {'is_active': 0});
  }
}
