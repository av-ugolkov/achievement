import 'package:achievement/data/entities/progress_entity.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_progress.dart';
import 'package:achievement/data/model/achievement_model.dart';
import 'package:achievement/data/model/progress_model.dart';
import 'package:achievement/ui/view_achievement_page/field_description_progress.dart';
import 'package:achievement/ui/view_achievement_page/inherited_description_progress.dart';
import 'package:achievement/ui/view_achievement_page/inherited_view_achievement_page.dart';
import 'package:flutter/material.dart';
import 'package:achievement/core/extensions.dart';
import 'package:heatmap_calendar/heatmap_calendar_month/heatmap_calendar_month.dart';

class DescriptionProgress extends StatefulWidget {
  @override
  _DescriptionProgressState createState() => _DescriptionProgressState();
}

class _DescriptionProgressState extends State<DescriptionProgress> {
  late DateTime _currentDateTime;
  late AchievementModel _achievementModel;
  late Future<ProgressModel> _futureProgressModel;
  late Map<String, ProgressDescription> _pd;

  @override
  void initState() {
    super.initState();

    _currentDateTime = DateTime.now().getDate();
    _pd = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _achievementModel = InheritedViewAchievementPage.of(context);
    _futureProgressModel =
        DbProgress.db.getProgress(_achievementModel.progressId);
  }

  @override
  void dispose() {
    super.dispose();
    _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProgressModel>(
      future: _futureProgressModel,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data;
          if (data != null) {
            if (_pd.isEmpty) {
              _pd = data.progressDescription;
            }
            return _heatMapCalendarMonth();
          }
        }
        return Container();
      },
    );
  }

  Widget _heatMapCalendarMonth() {
    return InheritedDescriptionProgress(
      progressDescription: _pd,
      child: Column(
        children: [
          HeatMapCalendarMonth(
            startDate: _achievementModel.createDate,
            finishDate: _achievementModel.finishDate,
            input: <DateTime, int>{},
            colorThresholds: <int, Color>{1: Colors.greenAccent},
            cellHeight: 24,
            spaceMonth: 10,
            onTapHeatMapDay: (dateTime) {
              var tempDate = dateTime;
              if (tempDate.hour > 12) {
                tempDate = tempDate.add(Duration(days: 1));
              }
              if (tempDate.getDate() != _currentDateTime) {
                setState(() {
                  _currentDateTime = tempDate.getDate();
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FieldDescriptionProgress(
              currentDateTime: _currentDateTime,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProgress() async {
    var progressModel = await _futureProgressModel;
    if (progressModel.id == -1) {
      var id = await DbProgress.db.getLastId();
      progressModel = ProgressModel(id: id, progressDescription: _pd);
      await DbProgress.db.insert(progressModel);

      _achievementModel.progressId = progressModel.id;
      await DbAchievement.db.update(_achievementModel);
    } else {
      progressModel.progressDescription = _pd;

      await DbProgress.db.update(progressModel);
    }
  }
}
