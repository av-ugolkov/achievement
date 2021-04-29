import '/model/remind_model.dart';
import 'package:sqflite/sqflite.dart';
import 'db_file.dart';

class DbRemind {
  DbRemind._();

  final String _nameTable = 'RemindDB';

  final String _id = 'id';
  final String _typeRepition = 'typeRepition';
  final String _dateTime = 'dateTime';

  static final DbRemind db = DbRemind._();

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE $_nameTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_typeRepition INTEGER, $_dateTime TEXT)',
    );
  }

  Future<int> getLastId() async {
    final list = await DbFile.db.query(_nameTable);
    var id = 0;
    list.forEach((remind) {
      var remindId = remind['id'] as int;
      if (remindId >= id) {
        id = remindId + 1;
      }
    });
    return id;
  }

  Future<RemindModel> getRemind(int id) async {
    if (id == -1) return RemindModel.empty;

    final list = await DbFile.db
        .query(_nameTable, where: '$_id = ?', whereArgs: <int>[id]);
    var remind = RemindModel.fromJson(list[id]);
    return remind;
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
      reminds.add(RemindModel.fromJson(list[id]));
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
