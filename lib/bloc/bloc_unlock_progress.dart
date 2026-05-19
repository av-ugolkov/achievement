import 'dart:async';

import 'package:achievement/bloc/bloc_base.dart';
import 'package:achievement/core/services/block_sync_service.dart';
import 'package:achievement/data/model/unlock_condition_model.dart';
import 'package:achievement/db/db_block_session.dart';
import 'package:achievement/db/db_unlock_condition.dart';

sealed class UnlockProgressState {}

class UnlockProgressLoading extends UnlockProgressState {}

class UnlockProgressTracking extends UnlockProgressState {
  final int usageMinutes;
  final int thresholdMinutes;
  final String targetAppName;
  final bool unlocked;

  UnlockProgressTracking({
    required this.usageMinutes,
    required this.thresholdMinutes,
    required this.targetAppName,
    required this.unlocked,
  });
}

enum UnlockProgressEvent { refresh }

class BlocUnlockProgress extends BlocBase {
  final StreamController<UnlockProgressState> _stateController =
      StreamController<UnlockProgressState>.broadcast();
  final StreamController<UnlockProgressEvent> _eventController =
      StreamController<UnlockProgressEvent>();

  Sink<UnlockProgressEvent> get inEvent => _eventController.sink;
  Stream<UnlockProgressState> get outState => _stateController.stream;

  Stream<UnlockProgressEvent> get _outEvent => _eventController.stream;
  Sink<UnlockProgressState> get _inState => _stateController.sink;

  BlocUnlockProgress() {
    _outEvent.listen(_handleEvent);
    _init();
  }

  @override
  void dispose() {
    _eventController.close();
    _stateController.close();
  }

  Future<void> _init() async {
    _eventController.add(UnlockProgressEvent.refresh);
  }

  void _handleEvent(UnlockProgressEvent event) {
    switch (event) {
      case UnlockProgressEvent.refresh:
        _handleRefresh();
    }
  }

  Future<void> _handleRefresh() async {
    _inState.add(UnlockProgressLoading());
    try {
      final sync = BlockSyncService();
      final usage = await sync.readTargetUsage();
      final threshold = await sync.readThreshold();
      final unlocked = await sync.isUnlockedToday();

      // Determine target app name from active condition
      String targetAppName = 'Achievement';
      final condition = await DbUnlockCondition.db.getActive();
      if (condition is TimeInAppCondition) {
        targetAppName = condition.targetAppName;
      }

      if (unlocked) {
        await DbBlockSession.db.markUnlocked();
      }

      _inState.add(UnlockProgressTracking(
        usageMinutes: usage,
        thresholdMinutes: threshold,
        targetAppName: targetAppName,
        unlocked: unlocked,
      ));
    } catch (e) {
      _inState.add(UnlockProgressTracking(
        usageMinutes: 0,
        thresholdMinutes: 60,
        targetAppName: 'Achievement',
        unlocked: false,
      ));
    }
  }
}
