import 'dart:io';
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

  static final DbAchievement db = DbAchievement._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'Achievement.db';
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $_achievemntTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_header TEXT, $_description TEXT, $_imagePath TEXT, $_createDate INTEGER, $_finishDate INTEGER)',
    );
  }

  Future<List<AchievementModel>> getAchievements() async {
    Database db = await database;
    final List<Map<String, dynamic>> achievemntMapList =
        await db.query(_achievemntTable);
    final List<AchievementModel> achievementsList = [];
    achievemntMapList.forEach((achievement) {
      achievementsList.add(AchievementModel.fromMap(achievement));
    });
    return achievementsList;
  }

  Future<int> getLastId() async {
    Database db = await database;
    final List<Map<String, dynamic>> achievemntMapList =
        await db.query(_achievemntTable);
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
    Database db = await database;
    achievement.id = await db.insert(_achievemntTable, achievement.toMap());
    return achievement;
  }

  Future<int> updateAchievement(AchievementModel achievement) async {
    Database db = await database;
    return await db.update(_achievemntTable, achievement.toMap(),
        where: '$_id = ?', whereArgs: [achievement.id]);
  }

  Future<int> deleteAchievement(int id) async {
    Database db = await database;
    return await db
        .delete(_achievemntTable, where: '$_id = ?', whereArgs: [id]);
  }
}
