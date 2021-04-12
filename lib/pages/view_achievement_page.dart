import 'dart:io';
import 'package:achievement/bridge/localization.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/enums.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:achievement/widgets/expandable_fab.dart';
import 'package:flutter/material.dart';

class ViewAchievementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settings = ModalRoute.of(context)!.settings;
    var achievementModel = settings.arguments as AchievementModel;
    return Scaffold(
      appBar: AppBar(
        title: Text(getLocaleOfContext(context).viewAchievementTitle),
      ),
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () {
              _setAchievementState(achievementModel, AchievementState.fail);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.block_outlined),
            color: Colors.red,
          ),
          ActionButton(
            onPressed: () {
              _setAchievementState(achievementModel, AchievementState.archived);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.archive_outlined),
            color: Colors.grey,
          ),
          ActionButton(
            onPressed: () {
              _setAchievementState(achievementModel, AchievementState.done);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.done),
            color: Colors.green,
          ),
          ActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create_achievement_page');
              _setAchievementState(achievementModel, AchievementState.active);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievementModel.header,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  achievementModel.description,
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 100,
            height: 100,
            child: achievementModel.imagePath.isEmpty
                ? Icon(
                    Icons.not_interested,
                    color: Colors.grey[300],
                    size: 100,
                  )
                : Image.file(
                    File(achievementModel.imagePath),
                  ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(FormateDate.yearMonthDay(achievementModel.createDate)),
              Text(FormateDate.yearMonthDay(achievementModel.finishDate))
            ],
          ),
          Checkbox(
              value: achievementModel.remindIds.isNotEmpty, onChanged: null),
          Container(
            child: (achievementModel.remindIds.isEmpty)
                ? null
                : _remindWidget(achievementModel.remindIds),
          )
        ],
      ),
    );
  }

  void _setAchievementState(
      AchievementModel achievementModel, AchievementState state) {
    achievementModel.state = state;
    DbAchievement.db.update(achievementModel);
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
                return Text(value.typeRepition.toString() +
                    ' ' +
                    value.remindDateTime.toString());
              }).toList());
        } else {
          return Container();
        }
      },
    );
  }
}
