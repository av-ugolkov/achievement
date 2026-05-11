import 'dart:io';
import 'package:achievement/bridge/localization.dart';
import 'package:achievement/core/page_manager.dart';
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
import 'package:path/path.dart' as path;
import 'package:achievement/core/extensions.dart';
import 'edit_remind_card/form_edit_remind_card.dart';

class EditAchievementPage extends StatefulWidget {
  const EditAchievementPage({super.key});

  @override
  State<EditAchievementPage> createState() => _EditAchievementPageState();
}

class _EditAchievementPageState extends State<EditAchievementPage> {
  final ChangedDateTimeRange _dateRangeAchievement = ChangedDateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late final TextEditingController _headerEditController;
  late final TextEditingController _descriptionEditController;
  final _imageBytes = <int>[];
  final _remindCards = <FormEditRemindCard>[];

  bool get _hasRemind => _remindCards.isNotEmpty;

  final AchievementModel _model = AchievementModel.empty;

  bool _initialized = false;
  Future<AchievementModel>? _loadFuture;

  @override
  void initState() {
    super.initState();
    var dateNow = DateTime.now().getDate();
    _dateRangeAchievement.start = dateNow;
    _dateRangeAchievement.end = dateNow.add(const Duration(days: 1));
    _headerEditController = TextEditingController();
    _descriptionEditController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      var settings = ModalRoute.of(context)?.settings;
      if (settings != null && settings.arguments != null) {
        var model = settings.arguments as AchievementModel;
        _model.setModel(model);
      }
      _loadFuture = _loadModel(_model);
    }
  }

  @override
  void dispose() {
    _headerEditController.dispose();
    _descriptionEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        PageManager.pop(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(getLocaleOfContext(context).create_achievement),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              PageManager.pop(context);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _submitForm(context);
          },
          child: const Icon(Icons.check),
        ),
        body: FutureBuilder(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _body();
            } else {
              return Container();
            }
          },
        ),
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
      if (_hasRemind) {
        for (var remind in _remindCards) {
          if (remind.remindModel.id == -1) {
            await DbRemind.db.insert(remind.remindModel);
          } else {
            await DbRemind.db.update(remind.remindModel);
          }
        }
      }

      if (_model.id == -1) {
        var achievement = AchievementModel(
          id: -1,
          header: _headerEditController.text,
          createDate: _dateRangeAchievement.start,
          finishDate: _dateRangeAchievement.end,
          description: _descriptionEditController.text,
          imagePath: '',
          remindIds: _remindCards.map((value) {
            return value.remindModel.id;
          }).toList(),
          progressId: _model.progressId,
        );
        await DbAchievement.db.insert(achievement);
        if (_imageBytes.isNotEmpty) {
          var imagePath = path.join(
              utils.docsDir.path, '${achievement.id}_${_imageBytes.hashCode}');
          var file = File(imagePath);
          await file.writeAsBytes(_imageBytes.toList());
          await file.create();
          achievement.imagePath = imagePath;
          await DbAchievement.db.update(achievement);
        }
        _createNotifications(achievement.id);
        if (!context.mounted) return;
        _closePage(context);
      } else {
        var imagePath = '';
        if (_imageBytes.isNotEmpty) {
          imagePath = path.join(
              utils.docsDir.path, '${_model.id}_${_imageBytes.hashCode}');
          var file = File(imagePath);
          await file.writeAsBytes(_imageBytes.toList());
          await file.create();
        }
        var achievement = AchievementModel(
          id: _model.id,
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
        _createNotifications(_model.id);
        if (!context.mounted) return;
        _closePage(context, achievement);
      }
    }
  }

  void _closePage(BuildContext context, [AchievementModel? achievement]) {
    if (achievement == null) {
      PageManager.pop(context);
    } else {
      PageManager.pop(context, achievement);
    }
  }

  void _createNotifications(int achievementId) {
    for (var remind in _remindCards) {
      LocalNotification.cancelNotification(remind.remindModel.id);
      LocalNotification.scheduleNotification(
          remind.remindModel.id,
          _headerEditController.text,
          _descriptionEditController.text,
          remind.remindModel.remindDateTime.dateTime,
          remind.remindModel.typeRepetition,
          achievementId);
    }
  }
}
