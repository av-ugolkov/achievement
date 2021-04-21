import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_progress.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/model/progress_model.dart';
import 'package:achievement/pages/view_achievement_page/field_description_progress.dart';
import 'package:flutter/material.dart';
import 'package:achievement/utils/extensions.dart';
import 'package:flutter_components/components/date_time_progress/date_time_progress.dart';

class DescriptionProgress extends StatefulWidget {
  final AchievementModel achievementModel;

  DescriptionProgress({required this.achievementModel});

  @override
  _DescriptionProgressState createState() => _DescriptionProgressState();
}

class _DescriptionProgressState extends State<DescriptionProgress> {
  late DateTime _currentDateTime;

  late Future<ProgressModel> _futureProgressModel;
  late ProgressDescription _progressDesc;

  @override
  void initState() {
    super.initState();

    _currentDateTime = DateTime.now().getDate();
    _futureProgressModel =
        DbProgress.db.getProgress(widget.achievementModel.progressId);
  }

  @override
  void dispose() {
    super.dispose();

    _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    return _dateTimeProgress();
  }

  Widget _dateTimeProgress() {
    return Container(
      child: Column(
        children: [
          DateTimeProgress(
            start: widget.achievementModel.createDate,
            finish: widget.achievementModel.finishDate,
            current: _currentDateTime,
            onChange: (dateTime) {
              _currentDateTime = dateTime;
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: FieldDescriptionProgress(),
          )
        ],
      ),
    );
  }

  /*Future<void> _onPressSetProgress(ProgressDescription? progressDesc) async {
    progressDesc = ProgressDescription(
        isDoAnythink: _isDoAnythink,
        description: _isDoAnythink ? _textEditingController.text : '');
  }*/

  Future<void> _saveProgress() async {
    var progressModel = await _futureProgressModel;
    if (progressModel.id == -1) {
      var id = await DbProgress.db.getLastId();
      progressModel = ProgressModel(id: id, progressDescription: {
        _currentDateTime.getDate().toIso8601String(): _progressDesc
      });
      await DbProgress.db.insert(progressModel);

      widget.achievementModel.progressId = progressModel.id;
      await DbAchievement.db.update(widget.achievementModel);
    } else {
      progressModel.progressDescription.putIfAbsent(
          _currentDateTime.getDate().toIso8601String(), () => _progressDesc);

      await DbProgress.db.update(progressModel);
    }
  }
}
