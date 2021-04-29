import 'dart:io';
import '/bridge/localization.dart';
import '/db/db_remind.dart';
import 'edit_date_time_progress.dart';
import 'edit_description_achievement.dart';
import 'edit_header_achievement.dart';
import 'edit_remind_panel.dart';
import '/core/changed_date_time_range.dart';
import '/core/local_notification.dart';
import '/core/utils.dart' as utils;
import '/db/db_achievement.dart';
import '/model/achievement_model.dart';
import '/ui/edit_achievement_page/remind_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;
import '/core/extensions.dart';

class EditAchievementPage extends StatelessWidget {
  final ChangedDateTimeRange _dateRangeAchievement = ChangedDateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _headerEditController = TextEditingController();
  final _descriptionEditController = TextEditingController();
  final List<int> _imageBytes = [];
  final _remindDays = <RemindDay>[];

  bool get _hasRemind => _remindDays.isNotEmpty;

  EditAchievementPage() {
    var dateNow = DateTime.now().getDate();
    _dateRangeAchievement.start = dateNow;
    _dateRangeAchievement.end = dateNow.add(Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(getLocaleOfContext(context).createAchievement),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _submitForm(context);
        },
        child: Icon(Icons.check),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              EditHeaderAchievement(
                headerEditingController: _headerEditController,
                imageBytes: _imageBytes,
              ),
              EditDescriptionAchievement(
                descriptionEditController: _descriptionEditController,
              ),
              EditDateTimeProgress(
                remindDays: _remindDays,
                dateRangeAchievement: _dateRangeAchievement,
              ),
              EditRemindPanel(
                  remindDays: _remindDays,
                  dateRangeAchievement: _dateRangeAchievement),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var id = await DbAchievement.db.getLastId();

      var imagePath = '';
      if (_imageBytes.isNotEmpty) {
        imagePath =
            path.join(utils.docsDir.path, '${id}_${_imageBytes.hashCode}');
        var file = File(imagePath);
        await file.writeAsBytes(_imageBytes.toList());
        await file.create();
      }
      if (_hasRemind) {
        var lastIndex = await DbRemind.db.getLastId();
        for (var remind in _remindDays) {
          remind.remindModel.id = lastIndex;
          await DbRemind.db.insert(remind.remindModel);
          ++lastIndex;
        }
      }

      var achievement = AchievementModel(
        id: id,
        header: _headerEditController.text,
        createDate: _dateRangeAchievement.start,
        finishDate: _dateRangeAchievement.end,
        description: _descriptionEditController.text,
        imagePath: imagePath,
        remindIds: _remindDays.map((value) {
          return value.remindModel.id;
        }).toList(),
        progressId: -1,
      );
      await DbAchievement.db.insert(achievement);
      _createNotifications();
      Navigator.pop(context);
    }
  }

  void _createNotifications() {
    for (var remind in _remindDays) {
      LocalNotification.scheduleNotification(
          remind.remindModel.id,
          _headerEditController.text,
          _descriptionEditController.text,
          remind.remindModel.remindDateTime.dateTime,
          remind.remindModel.typeRepition);
    }
  }
}
