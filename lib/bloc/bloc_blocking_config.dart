import 'dart:async';

import 'package:achievement/bloc/bloc_base.dart';
import 'package:achievement/core/services/block_sync_service.dart';
import 'package:achievement/data/model/blocked_app_model.dart';
import 'package:achievement/data/model/unlock_condition_model.dart';
import 'package:achievement/db/db_block_session.dart';
import 'package:achievement/db/db_blocked_app.dart';
import 'package:achievement/db/db_unlock_condition.dart';

sealed class BlockingConfigState {}

class BlockingConfigLoading extends BlockingConfigState {}

class BlockingConfigLoaded extends BlockingConfigState {
  final List<BlockedAppModel> blockedApps;
  final UnlockConditionModel? activeCondition;
  final bool sessionUnlocked;

  BlockingConfigLoaded({
    required this.blockedApps,
    required this.activeCondition,
    required this.sessionUnlocked,
  });
}

class BlockingConfigError extends BlockingConfigState {
  final String message;
  BlockingConfigError(this.message);
}

enum BlockingConfigEvent { load, refresh }

class BlocBlockingConfig extends BlocBase {
  final StreamController<BlockingConfigState> _stateController =
      StreamController<BlockingConfigState>.broadcast();
  final StreamController<BlockingConfigEvent> _eventController =
      StreamController<BlockingConfigEvent>();

  Sink<BlockingConfigEvent> get inEvent => _eventController.sink;
  Stream<BlockingConfigState> get outState => _stateController.stream;

  Stream<BlockingConfigEvent> get _outEvent => _eventController.stream;
  Sink<BlockingConfigState> get _inState => _stateController.sink;

  List<BlockedAppModel> _blockedApps = [];
  UnlockConditionModel? _activeCondition;

  BlocBlockingConfig() {
    _outEvent.listen(_handleEvent);
    _init();
  }

  Future<void> _init() async {
    _blockedApps = await DbBlockedApp.db.getAll();
    _activeCondition = await DbUnlockCondition.db.getActive();
    // Sync block list to SharedPreferences for native layer
    await BlockSyncService()
        .writeBlockList(_blockedApps.map((a) => a.packageName).toList());
    if (_activeCondition != null) {
      await _activeCondition!.syncToNative(BlockSyncService());
    }
    _eventController.add(BlockingConfigEvent.load);
  }

  @override
  void dispose() {
    _eventController.close();
    _stateController.close();
  }

  void _handleEvent(BlockingConfigEvent event) {
    switch (event) {
      case BlockingConfigEvent.load:
      case BlockingConfigEvent.refresh:
        _handleLoad();
    }
  }

  Future<void> _handleLoad() async {
    _inState.add(BlockingConfigLoading());
    try {
      final unlocked = await DbBlockSession.db.isUnlockedToday();
      _inState.add(BlockingConfigLoaded(
        blockedApps: _blockedApps,
        activeCondition: _activeCondition,
        sessionUnlocked: unlocked,
      ));
    } catch (e) {
      _inState.add(BlockingConfigError(e.toString()));
    }
  }

  Future<void> addBlockedApp(String packageName, String appName) async {
    final model = BlockedAppModel(
      id: 0,
      packageName: packageName,
      appName: appName,
      addedDate: DateTime.now(),
    );
    await DbBlockedApp.db.insert(model);
    _blockedApps = await DbBlockedApp.db.getAll();
    await BlockSyncService()
        .writeBlockList(_blockedApps.map((a) => a.packageName).toList());
    _eventController.add(BlockingConfigEvent.refresh);
  }

  Future<void> removeBlockedApp(String packageName) async {
    await DbBlockedApp.db.delete(packageName);
    _blockedApps = await DbBlockedApp.db.getAll();
    await BlockSyncService()
        .writeBlockList(_blockedApps.map((a) => a.packageName).toList());
    _eventController.add(BlockingConfigEvent.refresh);
  }

  Future<void> setUnlockCondition(UnlockConditionModel condition) async {
    await DbUnlockCondition.db.upsert(condition);
    _activeCondition = condition;
    await condition.syncToNative(BlockSyncService());
    _eventController.add(BlockingConfigEvent.refresh);
  }

  Future<void> markSessionUnlocked() async {
    await DbBlockSession.db.markUnlocked();
    await BlockSyncService().markUnlockedToday();
    _eventController.add(BlockingConfigEvent.refresh);
  }
}
