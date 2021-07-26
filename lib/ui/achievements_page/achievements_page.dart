import 'dart:convert';
import 'dart:developer';
import 'package:achievement/core/enums.dart';
import 'package:achievement/core/notification/payload.dart';
import 'package:achievement/data/model/achievement_model.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_file.dart';
import 'package:achievement/db/db_progress.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/ui/achievements_page/inherited_achievement_page.dart';
import 'package:achievement/ui/achievements_page/left_panel.dart';
import 'package:achievement/ui/achievements_page/list_achievement.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/core/notification/local_notification.dart';
import 'package:achievement/bridge/localization.dart';
import 'package:achievement/ui/common/loading_widgets.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';

class AchievementsPage extends StatefulWidget {
  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  bool _initDb = false;
  late AchievementState _state;
  set state(AchievementState value) {
    if (_state == value) return;
    _state = value;
  }

  @override
  void initState() {
    super.initState();
    LocalNotification.init(onSelectNotification);
    _state = AchievementState.active;
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload == null || payload.isEmpty) {
      return;
    }
    while (!_initDb) {}
    var p = Payload.fromJson(jsonDecode(payload) as Map<String, dynamic>);
    switch (p.command) {
      case 'open':
        var achievements = await DbAchievement.db.getList();
        var model = achievements[p.achievementId];
        var result = await Navigator.pushNamed(
            context, RouteViewAchievementPage,
            arguments: model);
        var newModel = result as AchievementModel;
        model.setModel(newModel);
        setState(() {});
        break;
      default:
        log('Error open achievement');
    }
  }

  Future<Database> _initDB() async {
    var database = await DbFile.db.initDB(
      onCreate: (db, version) async {
        await DbAchievement.db.createTable(db);
        await DbRemind.db.createTable(db);
        await DbProgress.db.createTable(db);
      },
    );
    _initDb = true;
    return database;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InheritedAchievementPage(
          state: _state,
          child: _TitleAchievementPage(),
        ),
        centerTitle: true,
      ),
      drawer: LeftPanel(
        currentState: _state,
        onChangeState: (value) {
          setState(() {
            state = value;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteEditeAchievementPage)
              .then((value) => setState(() {}));
        },
        child: Icon(Icons.add),
      ),
      body: InheritedAchievementPage(
        state: _state,
        child: FutureBuilder(
          future: _initDB(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return ListAchievement();
              } else if (snapshot.hasError) {
                return Container(
                  child: Center(
                    child: Text(snapshot.error.toString()),
                  ),
                );
              }
              return const Loading();
            }
            return const Loading();
          },
        ),
      ),
    );
  }
}

class _TitleAchievementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = InheritedAchievementPage.of(context);
    var title = _getTitleState(state);
    return Text(title);
  }

  String _getTitleState(AchievementState state) {
    switch (state) {
      case AchievementState.active:
        return getLocaleCurrent().active;
      case AchievementState.finished:
        return getLocaleCurrent().finished;
      case AchievementState.done:
        return getLocaleCurrent().done;
      case AchievementState.fail:
        return getLocaleCurrent().fail;
      case AchievementState.archived:
        return getLocaleCurrent().archived;
      default:
        throw Exception('Not found AchievementState');
    }
  }
}
