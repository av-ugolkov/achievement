import 'package:achievement/bridge/localization.dart';
import 'package:achievement/core/enums.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  final AchievementState currentState;
  final ValueChanged<AchievementState> onChangeState;
  const BottomNavigation({Key? key, required this.currentState, required this.onChangeState})
      : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final bottomNavigationItems = [
      BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events_outlined), label: getLocaleOfContext(context).active),
      BottomNavigationBarItem(
          icon: Icon(Icons.event_available_outlined), label: getLocaleOfContext(context).finished),
      BottomNavigationBarItem(
          icon: Icon(Icons.archive_outlined), label: getLocaleOfContext(context).archived),
    ];

    return BottomNavigationBar(
      items: bottomNavigationItems,
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: false,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          switch (_currentIndex) {
            case 0:
              _setAchievementState(AchievementState.active);
              break;
            case 1:
              _setAchievementState(AchievementState.finished);
              break;
            case 2:
              _setAchievementState(AchievementState.archived);
              break;
          }
        });
      },
    );
  }

  void _setAchievementState(AchievementState state) {
    widget.onChangeState(state);
  }
}
