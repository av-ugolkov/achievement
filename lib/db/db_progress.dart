import 'package:achievement/db/db_file.dart';
import 'package:achievement/data/model/progress_model.dart';
import 'package:sqflite/sqflite.dart';

class DbProgress {
  DbProgress._();

  final String _nameTable = 'ProgressDB';

  final String _id = 'id';
  final String _progressDescription = 'progressDescription';

  static final DbProgress db = DbProgress._();

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE $_nameTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_progressDescription TEXT)',
    );
  }

  Future<int> getLastId() async {
    final list = await DbFile.db.query(_nameTable);
    var id = 0;
    list.forEach((progress) {
      var progressId = progress['id'] as int;
      if (progressId >= id) {
        id = progressId + 1;
      }
    });
    return id;
  }

  Future<ProgressModel> getProgress(int id) async {
    if (id == -1) return ProgressModel.empty;

    final list = await DbFile.db
        .query(_nameTable, where: '$_id = ?', whereArgs: <int>[id]);
    var progress = ProgressModel.fromJson(list[id]);
    return progress;
  }

  Future<ProgressModel> insert(ProgressModel progressModel) async {
    progressModel.id =
        await DbFile.db.insert(_nameTable, progressModel.toJson());
    return progressModel;
  }

  Future<int> update(ProgressModel progressModel) async {
    return await DbFile.db.update(_nameTable, progressModel.toJson(),
        where: '$_id = ?', whereArgs: <int>[progressModel.id]);
  }

  Future<int> delete(int id) async {
    return await DbFile.db
        .delete(_nameTable, where: '$_id = ?', whereArgs: <int>[id]);
  }
}
