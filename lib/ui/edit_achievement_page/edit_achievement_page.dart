import 'dart:io';
import 'package:achievement/bridge/localization.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/enums.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/ui/edit_achievement_page/edit_description_achievement.dart';
import 'package:achievement/ui/edit_achievement_page/edit_header_achievement.dart';
import 'package:achievement/utils/local_notification.dart';
import 'package:achievement/utils/utils.dart' as utils;
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/ui/edit_achievement_page/remind_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_components/components/date_time_progress/date_time_progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:achievement/utils/extensions.dart';

class EditAchievementPage extends StatefulWidget {
  @override
  _EditAchievementPageState createState() => _EditAchievementPageState();
}

class _EditAchievementPageState extends State<EditAchievementPage> {
  late DateTimeRange _dateRangeAchievement;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _headerEditController = TextEditingController();
  final _descriptionEditController = TextEditingController();

  final List<int> _imageBytes = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isRemind = false;
  bool get _hasRemind => _remindDays.isNotEmpty;

  final _remindDays = <RemindDay>[];

  @override
  void initState() {
    super.initState();
    var dateNow = DateTime.now().getDate();
    _dateRangeAchievement = DateTimeRange(
      start: dateNow,
      end: dateNow.add(
        Duration(days: 1),
      ),
    );
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
        onPressed: _submitForm,
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
                imagePicker: _imagePicker,
                imageBytes: _imageBytes,
              ),
              EditDescriptionAchievement(
                descriptionEditController: _descriptionEditController,
              ),
              DateTimeProgress(
                start: _dateRangeAchievement.start,
                finish: _dateRangeAchievement.end,
                current: DateTime.now().getDate(),
                onChangeStart: (dateTime) async {
                  FocusScope.of(context).unfocus();
                  var selectDate = await showDatePicker(
                      context: context,
                      initialDate: dateTime,
                      firstDate: DateTime(0),
                      lastDate: _dateRangeAchievement.end);
                  setState(() {
                    if (selectDate != null) {
                      _dateRangeAchievement = DateTimeRange(
                        start: selectDate,
                        end: _dateRangeAchievement.end,
                      );
                      if (_hasRemind) {
                        _remindDays.removeWhere((remind) {
                          var start = remind.remindDateTime.dateTime
                              .compareTo(_dateRangeAchievement.start);
                          var end = remind.remindDateTime.dateTime
                              .compareTo(_dateRangeAchievement.end);
                          return start < 0 || end > 0;
                        });
                        for (var remindCustomDay in _remindDays) {
                          remindCustomDay
                              .setRangeDateTime(_dateRangeAchievement);
                        }
                      }
                    }
                  });
                },
                onChangeFinish: (dateTime) async {
                  FocusScope.of(context).unfocus();
                  var selectDate = await showDatePicker(
                      context: context,
                      initialDate: dateTime,
                      firstDate: _dateRangeAchievement.start,
                      lastDate: DateTime(9999));
                  setState(() {
                    if (selectDate != null) {
                      _dateRangeAchievement = DateTimeRange(
                        start: _dateRangeAchievement.start,
                        end: selectDate,
                      );
                      if (_hasRemind) {
                        _remindDays.removeWhere((remind) {
                          var start = remind.remindDateTime.dateTime
                              .compareTo(_dateRangeAchievement.start);
                          var end = remind.remindDateTime.dateTime
                              .compareTo(_dateRangeAchievement.end);
                          return start < 0 || end > 0;
                        });
                        for (var remindCustomDay in _remindDays) {
                          remindCustomDay
                              .setRangeDateTime(_dateRangeAchievement);
                        }
                      }
                    }
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getLocaleOfContext(context).remind,
                    style: TextStyle(fontSize: 14),
                  ),
                  Switch(
                    value: _isRemind,
                    onChanged: (value) {
                      setState(() {
                        _isRemind = value;

                        if (_remindDays.isEmpty) {
                          var remindDateTime = RemindDateTime.fromDateTime(
                              dateTime: _dateRangeAchievement.start);
                          var remindModel = RemindModel(
                              id: -1,
                              typeRepition: TypeRepition.none,
                              remindDateTime: remindDateTime);
                          var newRemindDay = RemindDay(
                            remindModel: remindModel,
                            callbackRemove: _removeCustomDay,
                          );
                          newRemindDay.setRangeDateTime(_dateRangeAchievement);
                          _remindDays.add(newRemindDay);
                        } else {
                          var reCreateRemindDays = <RemindDay>[];
                          for (var remindDay in _remindDays) {
                            var newRemindDay = RemindDay(
                              remindModel: remindDay.remindModel,
                              callbackRemove: _removeCustomDay,
                            );
                            newRemindDay
                                .setRangeDateTime(_dateRangeAchievement);
                            reCreateRemindDays.add(newRemindDay);
                          }
                          _remindDays.clear();
                          _remindDays.addAll(reCreateRemindDays);
                        }
                      });
                    },
                  )
                ],
              ),
              Container(
                child: _isRemind ? _remindsPanel() : null,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
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

  Widget _remindsPanel() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _remindDays),
          IconButton(
              icon: Icon(
                Icons.add_circle_outlined,
                size: 32,
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                setState(() {
                  var remindDateTime = RemindDateTime.fromDateTime(
                      dateTime: _dateRangeAchievement.start);
                  var remindModel = RemindModel(
                      id: -1,
                      typeRepition: TypeRepition.none,
                      remindDateTime: remindDateTime);
                  var newRemindDay = RemindDay(
                    remindModel: remindModel,
                    callbackRemove: _removeCustomDay,
                  );
                  newRemindDay.setRangeDateTime(_dateRangeAchievement);
                  _remindDays.add(newRemindDay);
                });
              }),
        ],
      ),
    );
  }

  void _removeCustomDay(RemindDay remindCustomDay) {
    setState(() {
      _remindDays.remove(remindCustomDay);
      if (_remindDays.isEmpty) {
        _isRemind = false;
      }
    });
  }
}
