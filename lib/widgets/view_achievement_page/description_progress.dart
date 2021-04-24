import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_progress.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/model/progress_model.dart';
import 'package:achievement/widgets/view_achievement_page/field_description_progress.dart';
import 'package:achievement/widgets/view_achievement_page/inherited_description_progress.dart';
import 'package:achievement/widgets/view_achievement_page/inherited_view_achievement_page.dart';
import 'package:flutter/material.dart';
import 'package:achievement/utils/extensions.dart';
import 'package:flutter_components/components/date_time_progress/date_time_progress.dart';

class DescriptionProgress extends StatefulWidget {
  @override
  _DescriptionProgressState createState() => _DescriptionProgressState();
}

class _DescriptionProgressState extends State<DescriptionProgress> {
  late DateTime _currentDateTime;
  late DateTime _dateProgress;
  late AchievementModel _achievementModel;
  late Future<ProgressModel> _futureProgressModel;
  late Map<String, ProgressDescription> _pd;

  @override
  void initState() {
    super.initState();

    _currentDateTime = DateTime.now().getDate();
    _dateProgress = _currentDateTime;
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
        if (snapshot.hasData) {
          var data = snapshot.data;
          if (data != null) {
            if (_pd.isEmpty) {
              _pd = data.progressDescription;
            }
            return _dateTimeProgress(data);
          }
        }
        return Container();
      },
    );
  }

  Widget _dateTimeProgress(ProgressModel progressModel) {
    return InheritedDescriptionProgress(
      progressDescription: _pd,
      child: Column(
        children: [
          DateTimeProgress(
            start: _achievementModel.createDate,
            finish: _achievementModel.finishDate,
            current: _dateProgress,
            onChange: (dateTime) {
              var tempDate = dateTime;
              if (tempDate.hour > 12) {
                tempDate = tempDate.add(Duration(days: 1));
              }
              if (tempDate.getDate() != _currentDateTime) {
                setState(() {
                  _dateProgress = dateTime;
                  _currentDateTime = tempDate.getDate();
                });
              }
            },
            onChanged: (date) {
              setState(() {
                _dateProgress = date;
                _currentDateTime = date;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: FieldDescriptionProgress(
              currentDateTime: _currentDateTime,
            ),
          )
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
