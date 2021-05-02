import 'package:achievement/core/page_routes.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_file.dart';
import 'package:achievement/db/db_progress.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    await DbFile.db.initDB(
      onCreate: (db, version) async {
        await DbAchievement.db.createTable(db);
        await DbRemind.db.createTable(db);
        await DbProgress.db.createTable(db);
      },
    );
    _nextPage();
  }

  void _nextPage() {
    Navigator.pushNamed(context, RouteAchievementPage);
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
