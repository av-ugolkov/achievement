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

    var achievements = await DbAchievement.db.getList();
    var achievemnt = achievements.firstWhere((model) {
      return model.remindId == remind.id;
    });
    if (achievemnt == null) {
      throw Exception('Ненайдено достижение для сознадия напоминания');
    }
    var title = achievemnt.header;
    var body = achievemnt.description;

    if (remind.typeRemind == TypeRemind.week) {
      for (var day in remind.reminds) {
        if (day.hour == null) continue;

        for (var i = 0;; ++i) {
          var d = achievemnt.createDate.add(Duration(days: i));
          if (d.weekday == day.day) {
            var scheduledDate =
                DateTime(d.year, d.month, d.day, day.hour, day.minute);
            LocalNotification.scheduleNotification(
                id: remind.id,
                scheduledDate: scheduledDate,
                title: title,
                body: body,
                dayOfWeek: true);
            break;
          }
        }
      }
    } else if (remind.typeRemind == TypeRemind.custom) {
      for (var day in remind.reminds) {
        LocalNotification.scheduleNotification(
            id: remind.id,
            scheduledDate: DateTime.parse(day.day).add(Duration(
              hours: day.hour,
              minutes: day.minute,
            )),
            title: title,
            body: body);
      }
    }
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
