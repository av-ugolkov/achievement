import 'dart:io';
import 'package:achievement/ui/common/icon_photo_widget.dart';
import 'package:achievement/ui/view_achievement_page/inherited_view_achievement_page.dart';
import 'package:flutter/material.dart';

class TitleViewAchievement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var achievementModel = InheritedViewAchievementPage.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            height: 75,
            child: achievementModel.imagePath.isEmpty
                ? IconPhotoWidget(size: 75)
                : Image.file(File(achievementModel.imagePath)),
          ),
          SizedBox(width: 4),
          TitleText(header: achievementModel.header),
        ],
      ),
    );
  }
}

class TitleText extends StatefulWidget {
  final String header;

  const TitleText({Key? key, required this.header}) : super(key: key);

  @override
  _TitleTextState createState() => _TitleTextState();
}

class _TitleTextState extends State<TitleText> {
  int _maxLines = 2;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: () => setState(() {
          _maxLines = _maxLines == 2 ? 100 : 2;
        }),
        child: Text(
          widget.header,
          maxLines: _maxLines,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }
}
