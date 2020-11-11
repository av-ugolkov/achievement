import 'dart:io';

import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  bool _isHaveImage = false;
  AchievementModel _achievementModel;

  AchievementCard(AchievementModel achievement) {
    _achievementModel = achievement;
    _isHaveImage = _achievementModel.imagePath.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _isHaveImage
                ? Center(child: Image.file(File(_achievementModel.imagePath)))
                : Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black54,
                      ),
                      child: Icon(
                        Icons.not_interested,
                        color: Colors.grey[300],
                        size: 55,
                      ),
                    ),
                  ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _achievementModel.header,
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _achievementModel.description,
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                  Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        dateTime(FormateDate.yearNumMonthDay(
                            _achievementModel.finishDate)),
                      ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text dateTime(String dateString) {
    return Text(
      dateString,
      textAlign: TextAlign.end,
      style: TextStyle(
          fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black45),
    );
  }
}
