import 'dart:io';
import 'dart:typed_data';
import 'package:achievement/utils/utils.dart' as utils;
import 'package:achievement/db/db_achievement.dart';
import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class CreateAchievementPage extends StatefulWidget {
  @override
  _CreateAchievementPageState createState() => _CreateAchievementPageState();
}

class _CreateAchievementPageState extends State<CreateAchievementPage> {
  DateTime _finishDateAchievement;
  final _formKey = GlobalKey<FormState>();

  final _controllerHeaderAchiv = TextEditingController();
  final _controllerDescriptionAchiv = TextEditingController();

  Uint8List _imageBytes = Uint8List(0);
  ImagePicker _imagePicker = new ImagePicker();

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
                //autofocus: true,
                maxLength: 100,
                decoration: InputDecoration(
                  enabledBorder: _outlineInputBorder(15, Colors.black54),
                  focusedBorder: _outlineInputBorder(15, Colors.blue),
                  errorBorder: _outlineInputBorder(15, Colors.red),
                  focusedErrorBorder: _outlineInputBorder(15, Colors.blue),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _controllerHeaderAchiv.clear();
                    },
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ),
                style: TextStyle(fontSize: 18),
                cursorHeight: 20,
                validator: (value) {
                  if (value.length == 0) {
                    return 'пустой заголовок';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _controllerDescriptionAchiv,
                maxLines: 5,
                maxLength: 250,
                decoration: InputDecoration(
                  enabledBorder: _outlineInputBorder(15, Colors.black54),
                  focusedBorder: _outlineInputBorder(15, Colors.blue),
                  errorBorder: _outlineInputBorder(15, Colors.red),
                  focusedErrorBorder: _outlineInputBorder(15, Colors.blue),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _controllerDescriptionAchiv.clear();
                    },
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ),
                style: TextStyle(fontSize: 14),
                cursorHeight: 16,
              ),
              SizedBox(height: 8),
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
                    //Navigator.of(context).pop();
                  },
                  iconSize: 100,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
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
                    Icon(Icons.date_range),
                    SizedBox(width: 10),
                    Text('${FormateDate.yearMonthDay(_finishDateAchievement)}'),
                  ],
                ),
              ),
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
      var achievement = AchievementModel(
          id,
          _controllerHeaderAchiv.text,
          _controllerDescriptionAchiv.text,
          imagePath,
          DateTime.now(),
          _finishDateAchievement);
      DbAchievement.db.insertAchievement(achievement);
      Navigator.pop(context);
    } else {
      //_showMessage(message: 'Form is not valid! Please review and correct');
    }
  }

  OutlineInputBorder _outlineInputBorder(double radius, Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color),
    );
  }
}
