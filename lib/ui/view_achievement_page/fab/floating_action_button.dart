import 'package:achievement/core/page_manager.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/data/model/achievement_model.dart';
import 'package:achievement/core/page_routes.dart';
import 'expandable_fab.dart';
import 'package:flutter/material.dart';

class FAB extends StatefulWidget {
  final AchievementModel model;
  final VoidCallback onUpdateModel;
  FAB({required this.model, required this.onUpdateModel});

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
            _closePage();
          },
          icon: const Icon(Icons.block_outlined),
          color: Colors.red,
        ),
        ActionButton(
          onPressed: () {
            _setAchievementState(AchievementState.archived);
            _closePage();
          },
          icon: const Icon(Icons.archive_outlined),
          color: Colors.grey,
        ),
        ActionButton(
          onPressed: () {
            _setAchievementState(AchievementState.done);
            _closePage();
          },
          icon: const Icon(Icons.done),
          color: Colors.green,
        ),
        ActionButton(
          onPressed: () async {
            var result = await PageManager.pushNamed(
              context,
              RouteEditeAchievementPage,
              arguments: widget.model,
            );
            if (result != null) {
              var model = result as AchievementModel;
              widget.model.setModel(model);
              _setAchievementState(AchievementState.active);
              widget.onUpdateModel();
            }
          },
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }

  void _closePage() {
    PageManager.pop(context, widget.model);
  }

  void _setAchievementState(AchievementState state) {
    widget.model.state = state;
    DbAchievement.db.update(widget.model);
  }
}
