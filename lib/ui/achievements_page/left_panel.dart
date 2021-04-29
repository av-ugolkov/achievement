import '/bridge/localization.dart';
import '/core/enums.dart';
import 'package:flutter/material.dart';

class LeftPanel extends StatefulWidget {
  final Function(AchievementState) onChangeState;
  LeftPanel({required this.onChangeState});
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

  Widget _customDrawer() {
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
            leading: Icon(
              Icons.emoji_events_outlined,
              size: _sizeIcon,
              color: Colors.yellow[600],
            ),
            title: Text(getLocaleOfContext(context).active),
            onTap: () {
              _setAchievementState(AchievementState.active);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.done_all_outlined,
              size: _sizeIcon,
              color: Colors.green,
            ),
            title: Text(getLocaleOfContext(context).done),
            onTap: () {
              _setAchievementState(AchievementState.done);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.block_outlined,
              size: _sizeIcon,
              color: Colors.red,
            ),
            title: Text(getLocaleOfContext(context).fail),
            onTap: () {
              _setAchievementState(AchievementState.fail);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.archive_outlined,
              size: _sizeIcon,
              color: Colors.grey,
            ),
            title: Text(getLocaleOfContext(context).archived),
            onTap: () {
              _setAchievementState(AchievementState.archived);
            },
          ),
          SizedBox(height: 25),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: _sizeIcon,
              color: Theme.of(context).accentColor,
            ),
            title: Text('Настройки'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _setAchievementState(AchievementState state) {
    widget.onChangeState(state);
    close();
  }

  void close() {
    Navigator.pop(context);
  }
}
