import 'dart:io';
import 'package:achievement/data/model/achievement_model.dart';
import 'package:achievement/core/formate_date.dart';
import 'package:achievement/ui/common/icon_photo_widget.dart';
import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;

  AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: achievement.imagePath.isEmpty
                ? IconPhotoWidget(size: 60)
                : Image.file(
                    File(achievement.imagePath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
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
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          achievement.description,
                          maxLines: 2,
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodySmall,
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
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
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
}
