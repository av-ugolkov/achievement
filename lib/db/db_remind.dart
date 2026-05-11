import 'package:achievement/data/model/remind_model.dart';
import 'package:sqflite/sqflite.dart';
import 'db_file.dart';

class DbRemind {
  DbRemind._();

  final String _nameTable = 'RemindDB';

  final String _id = 'id';
  final String _typeRepetition = 'typeRepetition';
  final String _dateTime = 'dateTime';

  static final DbRemind db = DbRemind._();

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE $_nameTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_typeRepetition INTEGER, $_dateTime TEXT)',
    );
  }

  Future<RemindModel> getRemind(int id) async {
    if (id == -1) return RemindModel.empty;

    final list = await DbFile.db
        .query(_nameTable, where: '$_id = ?', whereArgs: <int>[id]);
    if (list.isEmpty) return RemindModel.empty;
    return RemindModel.fromJson(list[0]);
  }

  Future<List<RemindModel>> getReminds(List<int> ids) async {
    var reminds = <RemindModel>[];
    for (var id in ids) {
      if (id == -1) {
        reminds.add(RemindModel.empty);
        continue;
      }
      final list = await DbFile.db
          .query(_nameTable, where: '$_id = ?', whereArgs: <int>[id]);
      if (list.isEmpty) continue;
      reminds.add(RemindModel.fromJson(list[0]));
    }
    return reminds;
  }

  Future<RemindModel> insert(RemindModel remindModel) async {
    remindModel.id = await DbFile.db.insert(_nameTable, remindModel.toJson());
    return remindModel;
  }

  Future<int> update(RemindModel remind) async {
    return await DbFile.db.update(_nameTable, remind.toJson(),
        where: '$_id = ?', whereArgs: <int>[remind.id]);
  }

  Future<int> delete(int id) async {
    return await DbFile.db
        .delete(_nameTable, where: '$_id = ?', whereArgs: <int>[id]);
  }
}
