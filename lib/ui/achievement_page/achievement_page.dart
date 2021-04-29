import 'dart:developer';
import '/bridge/localization.dart';
import '/core/enums.dart';
import '/page_routes.dart';
import '/ui/achievement_page/left_panel.dart';
import '/ui/achievement_page/list_achievement.dart';
import '/core/local_notification.dart';
import 'package:flutter/material.dart';

class AchievementPage extends StatefulWidget {
  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
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

class InheritedAchievementPage extends InheritedWidget {
  final AchievementState state;

  InheritedAchievementPage({required this.state, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedAchievementPage oldWidget) {
    return oldWidget.state != state;
  }

  static AchievementState of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<InheritedAchievementPage>()
          ?.state ??
      AchievementState.active;
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
