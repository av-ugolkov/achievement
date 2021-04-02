import 'dart:async';

import 'package:achievement/bloc/bloc_base.dart';
import 'package:achievement/enums.dart';

class BlocAchievementState extends BlocBase {
  AchievementState _state = AchievementState.active;

  final StreamController<AchievementState> _counterController =
      StreamController<AchievementState>();
  final StreamController<AchievementState> _eventController =
      StreamController<AchievementState>();

  Sink<AchievementState> get _inCounter => _counterController.sink;
  Stream<AchievementState> get outCounter => _counterController.stream;

  Sink<AchievementState> get inEvent => _eventController.sink;
  Stream<AchievementState> get _outEvent => _eventController.stream;

  BlocAchievementState() {
    _outEvent.listen(_handleEvent);
  }

  @override
  void dispose() {
    _eventController.close();
    _counterController.close();
  }

  void _handleEvent(AchievementState event) {
    _handleChangeStateEvent(event);
  }

  void _handleChangeStateEvent(AchievementState state) {
    _state = state;
    _inCounter.add(_state);
  }
}
