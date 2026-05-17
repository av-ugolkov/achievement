import 'dart:async';
import 'dart:developer';
import 'package:achievement/core/enums.dart';
import 'package:achievement/core/notification/payload.dart';
import 'package:achievement/core/page_manager.dart';
import 'package:achievement/data/model/achievement_model.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_file.dart';
import 'package:achievement/db/db_progress.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/ui/achievements_page/inherited_achievement_page.dart';
import 'package:achievement/ui/achievements_page/list_achievement.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/core/notification/local_notification.dart';
import 'package:achievement/bridge/localization.dart';
import 'package:achievement/ui/common/loading_widgets.dart';
import 'package:achievement/ui/common/popup_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:achievement/ui/achievements_page/bottom_navigation.dart';
import 'package:achievement/ui/app_usage_page/app_usage_page.dart';
import 'package:sqflite/sqflite.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late AchievementState _state;
  bool _showAppUsage = false;

  set state(AchievementState value) {
    if (_state == value) return;
    _state = value;
  }

  @override
  void initState() {
    super.initState();
    _state = AchievementState.active;

    PageManager.init(context);
  }

  Future<void> onLoadPayload(Payload payload) async {
    switch (payload.command) {
      case 'open':
        final navigator = Navigator.of(context);
        var achievements = await DbAchievement.db.getList();
        var model = achievements[payload.achievementId];
        LocalNotification.clearPayload();
        if (!mounted) return;
        var result = await navigator.pushNamed(routeViewAchievementPage,
            arguments: model);
        if (result is AchievementModel) {
          model.setModel(result);
          setState(() {});
        }
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
    return database;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: _showAppUsage
              ? Text(getLocaleCurrent().appUsageTitle)
              : InheritedAchievementPage(
                  state: _state,
                  child: _TitleAchievementPage(),
                ),
          actions: _showAppUsage ? [] : [PopupMenuWidget()]),
      floatingActionButton: _showAppUsage
          ? null
          : FloatingActionButton(
              onPressed: () {
                PageManager.pushNamed(context, routeEditAchievementPage)
                    .then((value) => setState(() {}));
              },
              child: Icon(Icons.add),
            ),
      bottomNavigationBar: BottomNavigation(
        currentState: _state,
        onChangeState: (value) {
          setState(() {
            _showAppUsage = false;
            state = value;
          });
        },
        onAppUsageTap: () {
          setState(() {
            _showAppUsage = true;
          });
        },
      ),
      body: _showAppUsage
          ? const AppUsagePage()
          : InheritedAchievementPage(
        state: _state,
        child: FutureBuilder(
          future: _initDB(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                if (LocalNotification.payload?.command != null) {
                  onLoadPayload(LocalNotification.payload!);
                } else {
                  return ListAchievement();
                }
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
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
      case AchievementState.archived:
        return getLocaleCurrent().archived;
    }
  }
}
