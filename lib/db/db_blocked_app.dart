import 'package:achievement/data/model/blocked_app_model.dart';
import 'package:achievement/db/db_file.dart';
import 'package:sqflite/sqflite.dart';

class DbBlockedApp {
  DbBlockedApp._();
  static final DbBlockedApp db = DbBlockedApp._();

  final String _table = 'BlockedAppDB';

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'package_name TEXT NOT NULL UNIQUE, '
      'app_name TEXT NOT NULL, '
      'added_date INTEGER NOT NULL)',
    );
  }

  Future<List<BlockedAppModel>> getAll() async {
    final rows = await DbFile.db.query(_table);
    return rows.map(BlockedAppModel.fromJson).toList();
  }

  Future<void> insert(BlockedAppModel model) async {
    final map = model.toJson()..remove('id');
    await DbFile.db.insert(_table, map);
  }

  Future<void> delete(String packageName) async {
    await DbFile.db.delete(_table,
        where: 'package_name = ?', whereArgs: [packageName]);
  }
}
