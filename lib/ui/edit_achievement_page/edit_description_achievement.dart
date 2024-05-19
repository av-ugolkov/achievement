import 'package:achievement/bridge/localization.dart';
import 'package:flutter/material.dart';

class EditDescriptionAchievement extends StatefulWidget {
  final TextEditingController descriptionEditController;

  EditDescriptionAchievement({required this.descriptionEditController});

  @override
  _EditDescriptionAchievementState createState() =>
      _EditDescriptionAchievementState();
}

class _EditDescriptionAchievementState
    extends State<EditDescriptionAchievement> {
  @override
  void dispose() {
    super.dispose();
    widget.descriptionEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.descriptionEditController,
      minLines: 1,
      maxLines: 5,
      maxLength: 250,
      decoration: InputDecoration(
        hintText: getLocaleOfContext(context).description,
        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      ),
      style: Theme.of(context).textTheme.titleMedium,
      cursorHeight: 18,
    );
  }
}
