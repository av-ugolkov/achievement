import 'package:achievement/bridge/localization.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/core/page_manager.dart';
import 'package:flutter/material.dart';

class LeftPanel extends StatefulWidget {
  final AchievementState currentState;
  final ValueChanged<AchievementState> onChangeState;
  LeftPanel({required this.currentState, required this.onChangeState});
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
            tileColor: _getBackgraundColorTile(AchievementState.active),
            leading: _getLeadingWidget(
              Icons.emoji_events_outlined,
              Colors.yellow[600],
            ),
            title: Text(getLocaleOfContext(context).active),
            onTap: () {
              _setAchievementState(AchievementState.active);
            },
          ),
          ListTile(
            tileColor: _getBackgraundColorTile(AchievementState.finished),
            leading: _getLeadingWidget(
              Icons.event_available_outlined,
              Colors.lightBlue,
            ),
            title: Text(getLocaleOfContext(context).finished),
            onTap: () {
              _setAchievementState(AchievementState.finished);
            },
          ),
          ListTile(
            tileColor: _getBackgraundColorTile(AchievementState.done),
            leading: _getLeadingWidget(
              Icons.done_all_outlined,
              Colors.green,
            ),
            title: Text(getLocaleOfContext(context).done),
            onTap: () {
              _setAchievementState(AchievementState.done);
            },
          ),
          ListTile(
            tileColor: _getBackgraundColorTile(AchievementState.fail),
            leading: _getLeadingWidget(
              Icons.block_outlined,
              Colors.red,
            ),
            title: Text(getLocaleOfContext(context).fail),
            onTap: () {
              _setAchievementState(AchievementState.fail);
            },
          ),
          ListTile(
            tileColor: _getBackgraundColorTile(AchievementState.archived),
            leading: _getLeadingWidget(
              Icons.archive_outlined,
              Colors.grey,
            ),
            title: Text(getLocaleOfContext(context).archived),
            onTap: () {
              _setAchievementState(AchievementState.archived);
            },
          ),
          SizedBox(height: 25),
          ListTile(
            leading: _getLeadingWidget(
              Icons.settings,
              Theme.of(context).accentColor,
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
    _closePage();
  }

  Color? _getBackgraundColorTile(AchievementState state) {
    if (widget.currentState == state) {
      return Colors.grey[300];
    } else {
      return Colors.white24;
    }
  }

  Icon _getLeadingWidget(IconData? iconData, Color? color) {
    return Icon(
      iconData,
      size: _sizeIcon,
      color: color,
    );
  }

  void _closePage() {
    PageManager.pop(context);
  }
}
