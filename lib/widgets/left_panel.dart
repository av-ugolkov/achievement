import 'package:achievement/bloc/bloc_achievement_state.dart';
import 'package:achievement/bloc/bloc_provider.dart';
import 'package:achievement/enums.dart';
import 'package:flutter/material.dart';

class LeftPanel extends StatefulWidget {
  @override
  _LeftPanelState createState() => _LeftPanelState();
}

class _LeftPanelState extends State<LeftPanel> {
  static const double _sizeHeaderIcon = 100;
  static const double _sizeIcon = 30;

  late BlocAchievementState _bloc;

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<BlocAchievementState>(context);
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
            onTap: () {
              _setAchievementState(AchievementState.active);
            },
          ),
          ListTile(
            leading: Icon(Icons.done_all, size: _sizeIcon),
            title: Text('Выполненые'),
            onTap: () {
              _setAchievementState(AchievementState.done);
            },
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
            onTap: () {
              _setAchievementState(AchievementState.fail);
            },
          ),
          ListTile(
            leading: Icon(Icons.archive, size: _sizeIcon),
            title: Text('Архивные'),
            onTap: () {
              _setAchievementState(AchievementState.archived);
            },
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

  void _setAchievementState(AchievementState state) {
    _bloc.inEvent.add(state);
    close();
  }

  void close() {
    Navigator.pop(context);
  }
}
