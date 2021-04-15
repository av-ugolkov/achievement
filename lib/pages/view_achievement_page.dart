import 'dart:io';
import 'package:achievement/bridge/localization.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/db/db_progress.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/enums.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/model/progress_model.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/widgets/expandable_fab.dart';
import 'package:flutter/material.dart';
import 'package:achievement/utils/extensions.dart';
import 'package:flutter_components/components/date_time_progress/date_time_progress.dart';

class ViewAchievementPage extends StatefulWidget {
  @override
  _ViewAchievementPageState createState() => _ViewAchievementPageState();
}

class _ViewAchievementPageState extends State<ViewAchievementPage> {
  late AchievementModel _achievementModel;
  late DateTime _currentDateTime;

  @override
  void initState() {
    super.initState();

    _currentDateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    var settings = ModalRoute.of(context)?.settings;
    _achievementModel = settings!.arguments as AchievementModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(getLocaleOfContext(context).viewAchievementTitle),
      ),
      floatingActionButton: _floatingActionButton(),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          _title(),
          _description(),
          _dateTimeProgress(),
          _reminds(),
        ],
      ),
    );
  }

  Widget _floatingActionButton() {
    return ExpandableFab(
      distance: 112.0,
      children: [
        ActionButton(
          onPressed: () {
            _setAchievementState(_achievementModel, AchievementState.fail);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.block_outlined),
          color: Colors.red,
        ),
        ActionButton(
          onPressed: () {
            _setAchievementState(_achievementModel, AchievementState.archived);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.archive_outlined),
          color: Colors.grey,
        ),
        ActionButton(
          onPressed: () {
            _setAchievementState(_achievementModel, AchievementState.done);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.done),
          color: Colors.green,
        ),
        ActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/create_achievement_page');
            _setAchievementState(_achievementModel, AchievementState.active);
          },
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 75,
          height: 75,
          child: _achievementModel.imagePath.isEmpty
              ? Icon(
                  Icons.not_interested,
                  color: Colors.grey[300],
                  size: 75,
                )
              : Image.file(
                  File(_achievementModel.imagePath),
                ),
        ),
        SizedBox(width: 4),
        DecoratedBox(
          decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.black, width: 2))),
          child: Text(
            _achievementModel.header,
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

  Widget _description() {
    if (_achievementModel.description.isEmpty) {
      return Container();
    }
    return Text(
      _achievementModel.description,
      style: TextStyle(fontSize: 18, color: Colors.black54),
    );
  }

  Widget _dateTimeProgress() {
    return Container(
      child: Column(
        children: [
          DateTimeProgress(
            start: _achievementModel.createDate,
            finish: _achievementModel.finishDate,
            current: _currentDateTime,
            onChange: (dateTime) {
              setState(() {
                _currentDateTime = dateTime;
              });
            },
          ),
          _descProgress()
        ],
      ),
    );
  }

  bool _isDoAnythink = false;
  final TextEditingController _textEditingController = TextEditingController();

  Widget _descProgress() {
    var progress = DbProgress.db.getProgress(_achievementModel.progressId);
    return FutureBuilder<ProgressModel>(
        future: progress,
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            if (_currentDateTime.isBefore(DateTime.now())) {
              var progress = snapshot.data;
              var progressDesc =
                  progress?.progressDescription[_currentDateTime];
              _isDoAnythink = progressDesc?.isDoAnythink ?? false;
              _textEditingController.text = '';
              return Row(
                children: [
                  TextField(
                    controller: _textEditingController,
                    readOnly: !_isDoAnythink,
                    textAlign: TextAlign.start,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.check_circle,
                      color: _isDoAnythink ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() async {
                        _isDoAnythink = !_isDoAnythink;
                        progressDesc ??= ProgressDescription(
                            isDoAnythink: _isDoAnythink,
                            description: _isDoAnythink
                                ? _achievementModel.description
                                : '');

                        if (progress?.id == -1) {
                          var id = await DbProgress.db.getLastId();
                          progress = ProgressModel(
                              id: id,
                              progressDescription: {
                                _currentDateTime.getDate(): progressDesc!
                              });
                          if (progress != null) {
                            await DbProgress.db.insert(progress!);
                          }
                        } else {
                          progress!.progressDescription = {
                            _currentDateTime.getDate(): progressDesc!
                          };

                          await DbProgress.db.update(progress!);
                        }
                      });
                    },
                    iconSize: 35,
                  ),
                ],
              );
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        });
  }

  Widget _reminds() {
    if (_achievementModel.remindIds.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        Container(
          child: (_achievementModel.remindIds.isEmpty)
              ? null
              : _remindWidget(_achievementModel.remindIds),
        )
      ],
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
