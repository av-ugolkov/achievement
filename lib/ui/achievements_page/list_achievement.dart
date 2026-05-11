import 'package:achievement/core/page_manager.dart';
import 'package:achievement/ui/achievements_page/inherited_achievement_page.dart';
import 'package:achievement/ui/achievements_page/achievement_card.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/core/notification/local_notification.dart';
import 'package:achievement/data/model/achievement_model.dart';
import 'package:achievement/ui/common/loading_widgets.dart';
import 'package:flutter/material.dart';

class ListAchievement extends StatefulWidget {
  const ListAchievement({super.key});

  @override
  State<ListAchievement> createState() => _ListAchievementState();
}

class _ListAchievementState extends State<ListAchievement> {
  late Future<List<AchievementModel>> _futureAchievements;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _futureAchievements = _loadAchievements();
    }
  }

  Future<List<AchievementModel>> _loadAchievements() async {
    final state = InheritedAchievementPage.of(context);
    final items = await DbAchievement.db.getAchievementsByState(state: state);
    if (state == AchievementState.active || state == AchievementState.finished) {
      for (var item in items) {
        final newState = item.finishDate.isAfter(DateTime.now())
            ? AchievementState.active
            : AchievementState.finished;
        if (item.state != newState) {
          item.state = newState;
          await DbAchievement.db.update(item);
        }
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AchievementModel>>(
      future: _futureAchievements,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final achievements = snapshot.data ?? [];
          if (achievements.isNotEmpty) {
            return ListView.builder(
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  var achievement = achievements[index];
                  return GestureDetector(
                    onTap: () {
                      _openViewAchievementPage(achievement);
                    },
                    child: Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                          child: Icon(Icons.archive)),
                      onDismissed: (direction) async {
                        await _archivedAchievement(achievement);
                      },
                      child: AchievementCard(achievement: achievement),
                    ),
                  );
                });
          }
          return Container();
        }
        return const Loading();
      },
    );
  }

  Future<void> _archivedAchievement(AchievementModel achievement) async {
    for (var remindId in achievement.remindIds) {
      await LocalNotification.cancelNotification(remindId);
    }
    achievement.state = AchievementState.archived;
    await DbAchievement.db.update(achievement);
  }

  void _openViewAchievementPage(AchievementModel model) async {
    var result = await PageManager.pushNamed(context, routeViewAchievementPage,
        arguments: model);
    if (result is AchievementModel) {
      model.setModel(result);
      setState(() {
        _futureAchievements = _loadAchievements();
      });
    }
  }
}
