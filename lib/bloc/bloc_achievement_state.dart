import 'dart:async';

import 'package:achievement/bloc/bloc_base.dart';
import 'package:achievement/enums.dart';

class BlocAchievementState extends BlocBase {
  late AchievementState _state;

  final StreamController<AchievementState> _stateController =
      StreamController<AchievementState>();
  final StreamController<AchievementState> _eventController =
      StreamController<AchievementState>();

  Sink<AchievementState> get _inState => _stateController.sink;
  Stream<AchievementState> get outState => _stateController.stream;

  Sink<AchievementState> get inEvent => _eventController.sink;
  Stream<AchievementState> get _outEvent => _eventController.stream;

  BlocAchievementState({AchievementState state = AchievementState.active}) {
    _state = state;
    _outEvent.listen(_handleEvent);
  }

  @override
  void dispose() {
    _eventController.close();
    _stateController.close();
  }

  void _handleEvent(AchievementState event) {
    _handleChangeStateEvent(event);
  }

  void _handleChangeStateEvent(AchievementState state) {
    _state = state;
    _inState.add(_state);
  }
}
