import 'package:flutter/material.dart';

class IconPhotoWidget extends StatelessWidget {
  final double size;
  const IconPhotoWidget({Key? key, this.size = 50}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.photo,
      size: size,
      color: Colors.grey[500],
    );
  }
}
