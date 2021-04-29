import 'dart:typed_data';
import '/bridge/localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditHeaderAchievement extends StatefulWidget {
  final TextEditingController headerEditingController;
  final List<int> imageBytes;

  EditHeaderAchievement({
    required this.headerEditingController,
    required this.imageBytes,
  });

  @override
  _EditHeaderAchievementState createState() => _EditHeaderAchievementState();
}

class _EditHeaderAchievementState extends State<EditHeaderAchievement> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    super.dispose();
    widget.headerEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.headerEditingController,
      maxLength: 100,
      decoration: InputDecoration(
        hintText: getLocaleOfContext(context).header,
        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        icon: IconButton(
          padding: EdgeInsets.all(0),
          icon: widget.imageBytes.isEmpty
              ? Icon(
                  Icons.photo,
                  size: 50,
                )
              : Image.memory(Uint8List.fromList(widget.imageBytes)),
          onPressed: () async {
            var galleryImage =
                await _imagePicker.getImage(source: ImageSource.gallery);
            if (galleryImage != null) {
              var newImage = await galleryImage.readAsBytes();
              if (widget.imageBytes.isNotEmpty) {
                widget.imageBytes.clear();
              }
              widget.imageBytes.addAll(newImage.toList());
              setState(() {});
            }
          },
        ),
      ),
      style: TextStyle(fontSize: 18),
      cursorHeight: 22,
      validator: (value) {
        if (value!.isEmpty || value.length < 3) {
          return getLocaleOfContext(context).header_error;
        }
        return null;
      },
    );
  }
}
