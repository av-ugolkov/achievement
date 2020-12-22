import 'dart:io';
import 'dart:typed_data';
import 'package:achievement/db/db_remind.dart';
import 'package:achievement/enums.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/utils/utils.dart' as utils;
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:achievement/widgets/remind_day_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class CreateEditAchievementPage extends StatefulWidget {
  @override
  _CreateEditAchievementPageState createState() =>
      _CreateEditAchievementPageState();
}

class _CreateEditAchievementPageState extends State<CreateEditAchievementPage> {
  DateTime _finishDateAchievement;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _controllerHeaderAchiv = TextEditingController();
  final _controllerDescriptionAchiv = TextEditingController();

  Uint8List _imageBytes = Uint8List(0);
  ImagePicker _imagePicker = new ImagePicker();

  bool _isRemind = false;
  TypeRemind _typeRemind = TypeRemind.none;
  RemindModel _remind = RemindModel.empty;

  @override
  void initState() {
    super.initState();
    _finishDateAchievement = DateTime.now().add(Duration(days: 1));
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
              Container(
                height: 100,
                child: IconButton(
                  icon: _imageBytes.isEmpty
                      ? Icon(Icons.photo)
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
              TextButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  var selectDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 100));
                  setState(() {
                    if (selectDate != null) {
                      _finishDateAchievement = selectDate;
                    }
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.date_range,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 10),
                    Text(
                      '${FormateDate.yearMonthDay(_finishDateAchievement)}',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Включить напоминание'),
                  Checkbox(
                    value: _isRemind,
                    onChanged: (value) async {
                      _typeRemind = await _getTypeRepeat(context);
                      setState(() {
                        _isRemind = _typeRemind != TypeRemind.none;
                      });
                    },
                  ),
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
          DateTime.now(),
          _finishDateAchievement,
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

  Future<TypeRemind> _getTypeRepeat(BuildContext context) async {
    TypeRemind typeRemind = TypeRemind.none;
    if (_typeRemind == TypeRemind.none) {
      await showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      title: new Text('Выбрать дни недели'),
                      onTap: () {
                        typeRemind = TypeRemind.week;
                        Navigator.pop(context);
                      }),
                  new ListTile(
                    title: new Text('Выбрать произвольные дни'),
                    onTap: () {
                      typeRemind = TypeRemind.custom;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          });
    }
    return typeRemind;
  }

  Container _weekRemind() {
    List<RemindDay> checkBoxs = List<RemindDay>();
    for (var i = 0; i < 7; ++i) {
      DateTime date = DateTime(1, 1, i + 1);
      RemindDay checkBox = RemindDay(title: '${FormateDate.weekDayName(date)}');
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
      child: Text('custom'),
    );
  }
}
