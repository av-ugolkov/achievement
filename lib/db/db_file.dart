import 'dart:io';

import 'package:achievement/user/config.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

@immutable
class DbFile {
  DbFile._();

  static final DbFile db = DbFile._();
  static Database _database;

  Future<void> initDB(
      {OnDatabaseCreateFn onCreate,
      OnDatabaseVersionChangeFn onUpgrade,
      OnDatabaseVersionChangeFn onDowngrade,
      OnDatabaseOpenFn onOpen}) async {
    String path = await _getPathDB();
    _database = await openDatabase(path,
        version: Config.version,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade,
        onOpen: onOpen);
    await _database.setVersion(Config.version);
  }

  Future<String> _getPathDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + '/Achievement.db';
    return path;
  }

  Future<void> setVersion(int version) async {
    await _database.setVersion(version);
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    return await _database.query(table);
  }

  Future<int> insert(String table, Map<String, dynamic> map) async {
    return await _database.insert(table, map);
  }

  Future<int> update(String table, Map<String, dynamic> map,
      {String where,
      List<dynamic> whereArgs,
      ConflictAlgorithm conflictAlgorithm}) async {
    return await _database.update(table, map,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm);
  }

  Future<int> delete(String table,
      {String where, List<dynamic> whereArgs}) async {
    return await _database.delete(table, where: where, whereArgs: whereArgs);
  }
}
