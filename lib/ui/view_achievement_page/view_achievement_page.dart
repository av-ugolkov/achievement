import 'dart:io';
import 'package:achievement/bridge/localization.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/enums.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/ui/view_achievement_page/description_progress.dart';
import 'package:achievement/ui/view_achievement_page/inherited_view_achievement_page.dart';
import 'package:achievement/ui/fab/floating_action_button.dart';
import 'package:flutter/material.dart';

class ViewAchievementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settings = ModalRoute.of(context)?.settings;
    var achievementModel = settings!.arguments as AchievementModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(getLocaleOfContext(context).viewAchievementTitle),
      ),
      floatingActionButton: FAB(),
      body: InheritedViewAchievementPage(
        model: achievementModel,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            _title(achievementModel),
            _description(achievementModel),
            DescriptionProgress(),
            _reminds(achievementModel),
          ],
        ),
      ),
    );
  }

  Widget _title(AchievementModel achievementModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 75,
          height: 75,
          child: achievementModel.imagePath.isEmpty
              ? Icon(
                  Icons.not_interested,
                  color: Colors.grey[300],
                  size: 75,
                )
              : Image.file(
                  File(achievementModel.imagePath),
                ),
        ),
        SizedBox(width: 4),
        DecoratedBox(
          decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.black, width: 2))),
          child: Text(
            achievementModel.header,
            maxLines: 2,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _description(AchievementModel achievementModel) {
    if (achievementModel.description.isEmpty) {
      return Container();
    }
    return Text(
      achievementModel.description,
      style: TextStyle(fontSize: 18, color: Colors.black54),
    );
  }

  Widget _reminds(AchievementModel achievementModel) {
    if (achievementModel.remindIds.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        Container(
          child: (achievementModel.remindIds.isEmpty)
              ? null
              : _remindWidget(achievementModel.remindIds),
        )
      ],
    );
  }

  Widget _remindWidget(List<int> ids) {
    var reminds = DbRemind.db.getReminds(ids);
    return FutureBuilder(
      future: reminds,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var reminds = snapshot.data as List<RemindModel>;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reminds.map((value) {
                return _remindCard(value);
              }).toList());
        } else {
          return Container();
        }
      },
    );
  }

  Widget _remindCard(RemindModel model) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.alarm),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(_getStringRepition(model)),
              Text(' в '),
              Text(model.remindDateTime.time),
            ],
          )
        ],
      ),
    );
  }

  String _getStringRepition(RemindModel model) {
    switch (model.typeRepition) {
      case TypeRepition.day:
        return 'каждый день';
      case TypeRepition.week:
        return 'каждую неделю';
      case TypeRepition.month:
        return 'каждый месяц';
      default:
        return model.remindDateTime.date;
    }
  }
}
