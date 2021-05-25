import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/core/page_routes.dart';
import 'expandable_fab.dart';
import 'package:flutter/material.dart';

class FAB extends StatefulWidget {
  final AchievementModel model;

  FAB({required this.model});

  @override
  _FABState createState() => _FABState();
}

class _FABState extends State<FAB> {
  @override
  Widget build(BuildContext context) {
    return _floatingActionButton();
  }

  Widget _floatingActionButton() {
    return ExpandableFab(
      distance: 112.0,
      children: [
        ActionButton(
          onPressed: () {
            _setAchievementState(AchievementState.fail);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.block_outlined),
          color: Colors.red,
        ),
        ActionButton(
          onPressed: () {
            _setAchievementState(AchievementState.archived);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.archive_outlined),
          color: Colors.grey,
        ),
        ActionButton(
          onPressed: () {
            _setAchievementState(AchievementState.done);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.done),
          color: Colors.green,
        ),
        ActionButton(
          onPressed: () {
            _setAchievementState(AchievementState.active);
            Navigator.pushNamed(
              context,
              RouteEditeAchievementPage,
              arguments: widget.model,
            );
          },
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }

  void _setAchievementState(AchievementState state) {
    widget.model.state = state;
    DbAchievement.db.update(widget.model);
  }
}
