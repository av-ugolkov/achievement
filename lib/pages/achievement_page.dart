import 'dart:developer';
import 'package:achievement/bloc/bloc_achievement_state.dart';
import 'package:achievement/bloc/bloc_provider.dart';
import 'package:achievement/bridge/localization.dart';
import 'package:achievement/enums.dart';
import 'package:achievement/utils/local_notification.dart';
import 'package:achievement/widgets/left_panel.dart';
import 'package:achievement/widgets/list_achievement.dart';
import 'package:flutter/material.dart';

class AchievementPage extends StatefulWidget {
  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  final BlocAchievementState bloc = BlocAchievementState();
  final ListAchievement listAchievement = ListAchievement();

  @override
  void initState() {
    super.initState();
    LocalNotification.init(onSelectNotification);
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
    var scaffold = Scaffold(
      appBar: AppBar(
        title: TitleAchievementPage(),
        centerTitle: true,
      ),
      drawer: LeftPanel(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_achievement_page')
              .then((value) => setState(() {}));
        },
        child: Icon(Icons.add),
      ),
      body: ListAchievement(),
    );

    var blocProvider = BlocProvider(
      bloc: bloc,
      child: scaffold,
    );
    return blocProvider;
  }
}

class TitleAchievementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<BlocAchievementState>(context);
    var title = _getTitleState(bloc.state);
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
