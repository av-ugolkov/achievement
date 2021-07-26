import 'dart:io';
import 'package:achievement/bridge/localization.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/ui/edit_achievement_page/edit_date_time_progress.dart';
import 'package:achievement/ui/edit_achievement_page/edit_description_achievement.dart';
import 'package:achievement/ui/edit_achievement_page/edit_header_achievement.dart';
import 'package:achievement/ui/edit_achievement_page/edit_remind_panel.dart';
import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/core/notification/local_notification.dart';
import 'package:achievement/core/utils.dart' as utils;
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/data/model/achievement_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;
import 'package:achievement/core/extensions.dart';
import 'edit_remind_card/form_edit_remind_card.dart';

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
  final _remindCards = <FormEditRemindCard>[];

  bool get _hasRemind => _remindCards.isNotEmpty;

  final AchievementModel _model = AchievementModel.empty;

  EditAchievementPage() {
    var dateNow = DateTime.now().getDate();
    _dateRangeAchievement.start = dateNow;
    _dateRangeAchievement.end = dateNow.add(Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    var settings = ModalRoute.of(context)?.settings;
    if (settings != null && settings.arguments != null) {
      var model = settings.arguments as AchievementModel;
      _model.setModel(model);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(getLocaleOfContext(context).create_achievement),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _submitForm(context);
        },
        child: Icon(Icons.check),
      ),
      body: FutureBuilder(
        future: _loadModel(_model),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _body();
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _body() {
    return Form(
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
              remindCards: _remindCards,
              dateRangeAchievement: _dateRangeAchievement,
            ),
            EditRemindPanel(
              remindCards: _remindCards,
              dateRangeAchievement: _dateRangeAchievement,
            ),
          ],
        ),
      ),
    );
  }

  Future<FormEditRemindCard> _remindCard(
      int id, ChangedDateTimeRange dateTimeRange) async {
    var remind = await DbRemind.db.getRemind(id);
    var remindCard =
        FormEditRemindCard(remindModel: remind, dateTimeRange: dateTimeRange);
    return remindCard;
  }

  Future<AchievementModel> _loadModel(AchievementModel model) async {
    if (model.id == -1) {
      return _model;
    }
    _dateRangeAchievement.start = model.createDate;
    _dateRangeAchievement.end = model.finishDate;
    _headerEditController.text = model.header;
    _descriptionEditController.text = model.description;
    for (var id in model.remindIds) {
      var rc = await _remindCard(id, _dateRangeAchievement);
      _remindCards.add(rc);
    }
    return model;
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var id = _model.id == -1 ? await DbAchievement.db.getLastId() : _model.id;

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
        for (var remind in _remindCards) {
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
        remindIds: _remindCards.map((value) {
          return value.remindModel.id;
        }).toList(),
        progressId: _model.progressId,
      );
      _createNotifications(); //TODO нужно создавать уведомления только тогда когда они были созданы или изменены
      if (_model.id == -1) {
        await DbAchievement.db.insert(achievement);
        Navigator.pop(context);
      } else {
        Navigator.pop(context, achievement);
      }
    }
  }

  void _createNotifications() {
    for (var remind in _remindCards) {
      LocalNotification.cancelNotification(remind.remindModel.id);
      LocalNotification.scheduleNotification(
          remind.remindModel.id,
          _headerEditController.text,
          _descriptionEditController.text,
          remind.remindModel.remindDateTime.dateTime,
          remind.remindModel.typeRepition,
          _model.id);
    }
  }
}
