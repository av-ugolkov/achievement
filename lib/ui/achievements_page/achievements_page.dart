import 'dart:developer';
import '/ui/achievements_page/inherited_achievement_page.dart';
import '/ui/achievements_page/left_panel.dart';
import '/ui/achievements_page/list_achievement.dart';
import '/core/enums.dart';
import '/core/page_routes.dart';
import '/core/local_notification.dart';
import '/bridge/localization.dart';
import 'package:flutter/material.dart';

class AchievementsPage extends StatefulWidget {
  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
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
    //var achievements = await DbAchievement.db.getList();
    switch (payload) {
      case 'open':
        log('Нужна обработка открытия ачивки');
        //var index = int.tryParse(payload);
        //openViewAchievementPage(achievements[index]);
        break;
      default:
        log('Error open achievement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InheritedAchievementPage(
          state: _state,
          child: TitleAchievementPage(),
        ),
        centerTitle: true,
      ),
      drawer: LeftPanel(
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
        child: ListAchievement(),
      ),
    );
  }
}

class TitleAchievementPage extends StatelessWidget {
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
