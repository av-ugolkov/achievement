import 'dart:io';

import 'package:achievement/model/achievement_model.dart';
import 'package:achievement/utils/formate_date.dart';
import 'package:flutter/material.dart';

Container achievementCard(AchievementModel achievement) {
  return Container(
    height: 78,
    padding: const EdgeInsets.all(5.0),
    decoration: BoxDecoration(),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: achievement.imagePath.isNotEmpty
              ? Center(child: Image.file(File(achievement.imagePath)))
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
                        achievement.header,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        achievement.description,
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
                      Text(
                        FormateDate.yearNumMonthDay(achievement.finishDate),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: Colors.black45),
                      ),
                    ]),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
