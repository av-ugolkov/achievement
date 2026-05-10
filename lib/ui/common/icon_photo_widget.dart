import 'package:flutter/material.dart';

class IconPhotoWidget extends StatelessWidget {
  final double size;
  const IconPhotoWidget({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.photo,
      size: size,
      color: Colors.grey[500],
    );
  }
}
