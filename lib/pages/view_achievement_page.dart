import 'dart:io';

import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:flutter/material.dart';

class ViewAchievementPage extends StatelessWidget {
  AchievementModel _achievementModel;

  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context).settings;
    _achievementModel = settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Достижение'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/create_achievement_page');
            },
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _achievementModel.header,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  _achievementModel.description,
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 100,
            height: 100,
            child: _achievementModel.imagePath.isEmpty
                ? Icon(
                    Icons.not_interested,
                    color: Colors.grey[300],
                    size: 100,
                  )
                : Image.file(
                    File(_achievementModel.imagePath),
                  ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(FormateDate.yearMonthDay(_achievementModel.createDate)),
              Text(FormateDate.yearMonthDay(_achievementModel.finishDate))
            ],
          ),
          Text(_achievementModel.isRemind ? 'isRemind' : '!isRemind')
        ],
      ),
    );
  }
}
