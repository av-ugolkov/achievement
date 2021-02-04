import 'package:achievement/model/remind_model.dart';
import 'package:sqflite/sqflite.dart';

import 'db_file.dart';

class DbRemind {
  DbRemind._();

  final String _nameTable = 'RemindDB';

  final String _id = 'id';
  final String _typeRemind = 'typeRemind';
  final String _reminds = 'reminds';

  static final DbRemind db = DbRemind._();

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE $_nameTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_typeRemind INTEGER, $_reminds TEXT)',
    );
  }

  Future<int> getLastId() async {
    final List<Map<String, dynamic>> list = await DbFile.db.query(_nameTable);
    int id = 0;
    list.forEach((remind) {
      if (remind['id'] >= id) {
        id = remind['id'] + 1;
      }
    });
    return id;
  }

  Future<RemindModel> getRemind(int id) async {
    if (id == -1) return RemindModel.empty;

    final List<Map<String, dynamic>> list =
        await DbFile.db.query(_nameTable, where: '$_id = ?', whereArgs: [id]);
    RemindModel remind = RemindModel.fromMap(list[id]);
    return remind;
  }

  Future<RemindModel> insert(RemindModel remind) async {
    remind.id = await DbFile.db.insert(_nameTable, remind.toMap());
    return remind;
  }

  Future<int> update(RemindModel remind) async {
    return await DbFile.db.update(_nameTable, remind.toMap(),
        where: '$_id = ?', whereArgs: [remind.id]);
  }

  Future<int> delete(int id) async {
    return await DbFile.db
        .delete(_nameTable, where: '$_id = ?', whereArgs: [id]);
  }
}
