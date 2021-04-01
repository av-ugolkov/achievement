import 'package:achievement/model/achievement_model.dart';
import 'package:sqflite/sqflite.dart';

import 'db_file.dart';

class DbAchievement {
  DbAchievement._();

  final String _nameTable = 'AchievementDB';

  final String _id = 'id';
  final String _header = 'header';
  final String _description = 'description';
  final String _imagePath = 'image_path';
  final String _createDate = 'create_date';
  final String _finishDate = 'finish_date';
  final String _remindIds = 'remind_ids';
  final String _state = 'state';

  static final DbAchievement db = DbAchievement._();

  Future<void> createTable(Database db) async {
    await db.execute(
      'CREATE TABLE $_nameTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_header TEXT, $_description TEXT, $_imagePath TEXT, $_createDate INTEGER, $_finishDate INTEGER, $_remindIds TEXT, $_state INTEGER)',
    );
  }

  /*void _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute("ALTER TABLE $_nameTable ADD COLUMN test INTEGER");

    await db.setVersion(newVersion);
  }*/

  /*void _downgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute(
      'CREATE TABLE $_achievemntTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_header TEXT, $_description TEXT, $_imagePath TEXT, $_createDate INTEGER, $_finishDate INTEGER)',
    );

    await db.setVersion(newVersion);
  }*/

  Future<List<AchievementModel>> getList() async {
    final achievemntMapList = await DbFile.db.query(_nameTable);
    final achievementsList = <AchievementModel>[];
    achievemntMapList.forEach((achievement) {
      achievementsList.add(AchievementModel.fromMap(achievement));
    });
    return achievementsList;
  }

  Future<int> getLastId() async {
    final list = await DbFile.db.query(_nameTable);
    var id = 0;
    list.forEach((achievement) {
      var achievId = achievement['id'] as int;
      if (achievId >= id) {
        id = achievId + 1;
      }
    });
    return id;
  }

  Future<AchievementModel> insert(AchievementModel achievement) async {
    achievement.id = await DbFile.db.insert(_nameTable, achievement.toMap());
    return achievement;
  }

  Future<int> update(AchievementModel achievement) async {
    return await DbFile.db.update(_nameTable, achievement.toMap(),
        where: '$_id = ?', whereArgs: <int>[achievement.id]);
  }

  Future<int> delete(int id) async {
    return await DbFile.db
        .delete(_nameTable, where: '$_id = ?', whereArgs: <int>[id]);
  }
}
