import 'package:flutter/material.dart';

class LeftPanel extends StatefulWidget {
  @override
  _LeftPanelState createState() => _LeftPanelState();
}

class _LeftPanelState extends State<LeftPanel> {
  static const double _sizeHeaderIcon = 100;
  static const double _sizeIcon = 30;

  @override
  Widget build(BuildContext context) {
    return _customDrawer();
  }

  Drawer _customDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: Icon(
            Icons.accessibility_new,
            size: _sizeHeaderIcon,
            color: Colors.grey,
          )),
          ListTile(
            leading: Icon(Icons.emoji_events, size: _sizeIcon),
            title: Text('Активные'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.done_all, size: _sizeIcon),
            title: Text('Выполненые'),
            onTap: () {},
          ),
          ListTile(
            leading: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Icon(Icons.emoji_events_outlined),
                Icon(Icons.block_outlined, size: _sizeIcon)
              ],
            ),
            title: Text('Проваленные'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.archive, size: _sizeIcon),
            title: Text('Архивные'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings, size: _sizeIcon),
            title: Text('Настройки'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
