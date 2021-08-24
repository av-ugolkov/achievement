import 'dart:developer';

import 'package:flutter/material.dart';

class PopupMenuWidget extends StatefulWidget {
  const PopupMenuWidget({Key? key}) : super(key: key);

  @override
  _PopupMenuWidgetState createState() => _PopupMenuWidgetState();
}

enum _TypeMenu { settings, about }

class _PopupMenuWidgetState extends State<PopupMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_TypeMenu>(
      itemBuilder: (context) {
        return <PopupMenuItem<_TypeMenu>>[
          PopupMenuItem<_TypeMenu>(
            value: _TypeMenu.settings,
            child: Text('Настройки'),
          ),
          PopupMenuItem<_TypeMenu>(
            value: _TypeMenu.about,
            child: Text('О приложении'),
          )
        ];
      },
      onSelected: (value) {
        log(value.index.toString());
      },
    );
  }
}
