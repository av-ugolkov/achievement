import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/enums.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/utils/local_notification.dart';
import 'package:sqflite/sqflite.dart';

import 'db_file.dart';

class DbRemind {
  DbRemind._();

  final String _nameTable = 'RemindDB';

  final String _id = 'id';
  final String _typeRepition = 'typeRepition';
  final String _reminds = 'reminds';

  static final DbRemind db = DbRemind._();

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE $_nameTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_typeRepition INTEGER, $_reminds TEXT)',
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

  Future<List<RemindModel>> getReminds(List<int> ids) async {
    List<RemindModel> reminds = [];
    for (var id in ids) {
      if (id == -1) {
        reminds.add(RemindModel.empty);
        continue;
      }
      final List<Map<String, dynamic>> list =
          await DbFile.db.query(_nameTable, where: '$_id = ?', whereArgs: [id]);
      reminds.add(RemindModel.fromMap(list[id]));
    }
    return reminds;
  }

  Future<RemindModel> insert(RemindModel remindModel) async {
    remindModel.id = await DbFile.db.insert(_nameTable, remindModel.toMap());
    return remindModel;
  }

  void _setScheduleNotification(int id, DateTime scheduledDate, String title,
      String body, bool dayOfWeek) {
    LocalNotification.scheduleNotification(
        id: id,
        scheduledDate: scheduledDate,
        title: title,
        body: body,
        dayOfWeek: dayOfWeek);
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
