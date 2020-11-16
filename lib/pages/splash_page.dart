import 'dart:async';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_file.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/pages/achievement_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    DbFile.db.initDB(
      onCreate: (db, version) {
        DbAchievement.db.createTable();
        DbRemind.db.createTable();
        _nextPage();
      },
      onOpen: (db) {
        _nextPage();
      },
    );
  }

  void _nextPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AchievementPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Center(
          child: LinearProgressIndicator(),
        ),
      ),
    );
  }
}
