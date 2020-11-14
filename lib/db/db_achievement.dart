import 'dart:io';
import 'package:achievement/user/config.dart';

import '../model/achievement_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbAchievement {
  DbAchievement._();

  final String _achievemntTable = 'AchievementDB';
  final String _id = 'id';
  final String _header = 'header';
  final String _description = 'description';
  final String _imagePath = 'image_path';
  final String _createDate = 'create_date';
  final String _finishDate = 'finish_date';
  final String _isRemind = 'is_remind';

  static final DbAchievement db = DbAchievement._();
  static Database _database;

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    int version = Config.version;
    String path = dir.path + 'Achievement.db';
    return await openDatabase(path,
        version: version,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
        onDowngrade: _downgradeDB);
  }

  void _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $_achievemntTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_header TEXT, $_description TEXT, $_imagePath TEXT, $_createDate INTEGER, $_finishDate INTEGER, $_isRemind INTEGER)',
    );

    await db.setVersion(version);
  }

  void _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db
        .execute("ALTER TABLE $_achievemntTable ADD COLUMN $_isRemind INTEGER");

    await db.setVersion(newVersion);
  }

  void _downgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute(
      'CREATE TABLE $_achievemntTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_header TEXT, $_description TEXT, $_imagePath TEXT, $_createDate INTEGER, $_finishDate INTEGER)',
    );

    await db.setVersion(newVersion);
  }

  Future<void> initDB() async {
    _database = await _initDB();
  }

  Future<List<AchievementModel>> getAchievements() async {
    final List<Map<String, dynamic>> achievemntMapList =
        await _database.query(_achievemntTable);
    final List<AchievementModel> achievementsList = [];
    achievemntMapList.forEach((achievement) {
      achievementsList.add(AchievementModel.fromMap(achievement));
    });
    return achievementsList;
  }

  Future<int> getLastId() async {
    final List<Map<String, dynamic>> achievemntMapList =
        await _database.query(_achievemntTable);
    int id = 0;
    achievemntMapList.forEach((achievement) {
      if (achievement['id'] >= id) {
        id = achievement['id'] + 1;
      }
    });
    return id;
  }

  Future<AchievementModel> insertAchievement(
      AchievementModel achievement) async {
    achievement.id =
        await _database.insert(_achievemntTable, achievement.toMap());
    return achievement;
  }

  Future<int> updateAchievement(AchievementModel achievement) async {
    return await _database.update(_achievemntTable, achievement.toMap(),
        where: '$_id = ?', whereArgs: [achievement.id]);
  }

  Future<int> deleteAchievement(int id) async {
    return await _database
        .delete(_achievemntTable, where: '$_id = ?', whereArgs: [id]);
  }
}
