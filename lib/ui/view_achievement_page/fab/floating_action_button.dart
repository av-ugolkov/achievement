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
  late ExpandableFab _fab;

  @override
  Widget build(BuildContext context) {
    return _floatingActionButton();
  }

  Widget _floatingActionButton() {
    _fab = ExpandableFab(
      distance: 112.0,
      children: [
        ActionButton(
          onPressed: () {
            _setAchievementState(AchievementState.archived);
            _closePage();
          },
          icon: const Icon(Icons.archive_outlined),
          color: Colors.grey,
        ),
        ActionButton(
          onPressed: () async {
            _fab.hide();
            var result = await PageManager.pushNamed(
              context,
              RouteEditAchievementPage,
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
    return _fab;
  }

  void _closePage() {
    _fab.hide();
    PageManager.pop(context, widget.model);
  }

  void _setAchievementState(AchievementState state) {
    widget.model.state = state;
    DbAchievement.db.update(widget.model);
  }
}
