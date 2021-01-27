import 'dart:io';
import 'dart:typed_data';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/enums.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/utils/utils.dart' as utils;
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:achievement/widgets/remind_custom_day_widget.dart';
import 'package:achievement/widgets/remind_week_day_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class CreateEditAchievementPage extends StatefulWidget {
  @override
  _CreateEditAchievementPageState createState() =>
      _CreateEditAchievementPageState();
}

class _CreateEditAchievementPageState extends State<CreateEditAchievementPage> {
  DateTimeRange _dateRangeAchievement;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _controllerHeaderAchiv = TextEditingController();
  final _controllerDescriptionAchiv = TextEditingController();

  Uint8List _imageBytes = Uint8List(0);
  ImagePicker _imagePicker = new ImagePicker();

  bool _isRemind = false;
  TypeRemind _typeRemind = TypeRemind.none;
  RemindModel _remind = RemindModel.empty;

  List<RemindCustomDay> _remindCustomDay = <RemindCustomDay>[];

  @override
  void initState() {
    super.initState();
    _dateRangeAchievement = DateTimeRange(
        start: DateTime.now(), end: DateTime.now().add(Duration(days: 1)));
  }

  @override
  void dispose() {
    _controllerHeaderAchiv.dispose();
    _controllerDescriptionAchiv.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Создать достижение'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _submitForm,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: ListView(
            children: [
              TextFormField(
                controller: _controllerHeaderAchiv,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: 'Заголовок',
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, -6),
                ),
                style: TextStyle(fontSize: 18),
                cursorHeight: 22,
                validator: (value) {
                  if (value.length == 0) {
                    return 'Заголовок не может быть пустым';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controllerDescriptionAchiv,
                minLines: 1,
                maxLines: 3,
                maxLength: 250,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, -10),
                ),
                style: TextStyle(fontSize: 14),
                cursorHeight: 18,
              ),
              TextButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  var selectDate = await showDateRangePicker(
                      context: context,
                      initialDateRange: _dateRangeAchievement,
                      firstDate: DateTime(0),
                      lastDate: DateTime(9999));
                  setState(() {
                    if (selectDate != null) {
                      _dateRangeAchievement = selectDate;
                      if (_remindCustomDay.length > 0) {
                        _remindCustomDay.removeWhere((remind) {
                          var start = remind.remindDateTime
                              .compareTo(_dateRangeAchievement.start);
                          var end = remind.remindDateTime
                              .compareTo(_dateRangeAchievement.end);
                          return start < 0 || end > 0;
                        });
                      }
                    }
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.date_range,
                      color: Colors.black87,
                      size: 22,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${FormateDate.yearMonthDay(_dateRangeAchievement.start)}   -   ${FormateDate.yearMonthDay(_dateRangeAchievement.end)}',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                child: IconButton(
                  icon: _imageBytes.isEmpty
                      ? Icon(
                          Icons.photo,
                          size: 50,
                        )
                      : Image.memory(_imageBytes),
                  onPressed: () async {
                    var galleryImage = await _imagePicker.getImage(
                        source: ImageSource.gallery);
                    if (galleryImage != null) {
                      _imageBytes = await galleryImage.readAsBytes();
                      setState(() {});
                    }
                  },
                  iconSize: 100,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Напоминать',
                    style: TextStyle(fontSize: 14),
                  ),
                  DropdownButton(
                    value: _typeRemind,
                    onChanged: (value) {
                      setState(() {
                        _typeRemind = value;
                      });
                    },
                    items: TypeRemind.values.map<DropdownMenuItem>((value) {
                      return DropdownMenuItem(
                        child: Text(
                          _getStringRemind(value),
                          style: TextStyle(fontSize: 14),
                        ),
                        value: value,
                      );
                    }).toList(),
                  )
                ],
              ),
              Container(
                  child: (_typeRemind == TypeRemind.week)
                      ? _weekRemind()
                      : (_typeRemind == TypeRemind.custom)
                          ? _customRemind()
                          : Container())
            ],
          ),
        ),
      ),
    );
  }

  String _getStringRemind(TypeRemind typeRemind) {
    switch (typeRemind) {
      case TypeRemind.week:
        return 'по дням недели';
      case TypeRemind.custom:
        return 'по выборочным дням';
      default:
        return 'нет';
    }
  }

  void _submitForm() async {
    if (_formKey.currentState.validate()) {
      var id = await DbAchievement.db.getLastId();

      var imagePath = '';
      if (_imageBytes.isNotEmpty) {
        imagePath =
            path.join(utils.docsDir.path, "${id}_${_imageBytes.hashCode}");
        File file = File(imagePath);
        file.writeAsBytes(_imageBytes.toList());
        file.create();
      }
      if (_isRemind) {
        _remind.id = await DbRemind.db.getLastId();
        _remind.hour = 12;
        _remind.minute = 30;
        DbRemind.db.insert(_remind);
      } else {
        _remind = RemindModel.empty;
      }

      var achievement = AchievementModel(
          id,
          _controllerHeaderAchiv.text,
          _controllerDescriptionAchiv.text,
          imagePath,
          _dateRangeAchievement.start,
          _dateRangeAchievement.end,
          _remind.id);
      DbAchievement.db.insert(achievement);
      Navigator.pop(context);
    } else {
      _showMessage(message: 'Form is not valid! Please review and correct');
    }
  }

  void _showMessage({String message}) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Container _weekRemind() {
    List<RemindWeekDay> checkBoxs = [];
    for (var i = 0; i < 7; ++i) {
      DateTime date = DateTime(1, 1, i + 1);
      RemindWeekDay checkBox =
          RemindWeekDay(title: '${FormateDate.weekDayName(date)}');
      checkBoxs.add(checkBox);
    }
    return Container(
      child: Column(
        children: checkBoxs,
      ),
    );
  }

  Container _customRemind() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _remindCustomDay),
          IconButton(
              icon: Icon(
                Icons.add_circle_outlined,
                size: 32,
              ),
              onPressed: () {
                setState(() {
                  var newRemindCustom = RemindCustomDay(
                    dateRangeAchiv: _dateRangeAchievement,
                    callbackRemove: _removeCustomDay,
                  );
                  _remindCustomDay.add(newRemindCustom);
                });
              }),
        ],
      ),
    );
  }

  void _removeCustomDay(RemindCustomDay remindCustomDay) {
    setState(() {
      _remindCustomDay.remove(remindCustomDay);
    });
  }
}
