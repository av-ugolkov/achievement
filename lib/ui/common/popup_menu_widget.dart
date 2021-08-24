import 'dart:developer';

import 'package:achievement/core/page_manager.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:flutter/material.dart';

enum _TypeMenu { settings, about }

class PopupMenuWidget extends StatefulWidget {
  const PopupMenuWidget({Key? key}) : super(key: key);

  @override
  _PopupMenuWidgetState createState() => _PopupMenuWidgetState();
}

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
        switch (value) {
          case _TypeMenu.settings:
            PageManager.pushNamed(context, RouteSettingsPage);
            break;
          case _TypeMenu.about:
            PageManager.pushNamed(context, RouteAboutPage);
            break;
          default:
        }
      },
    );
  }
}
