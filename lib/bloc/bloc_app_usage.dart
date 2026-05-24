import 'dart:async';
import 'package:achievement/bloc/bloc_base.dart';
import 'package:achievement/core/services/app_usage_service.dart';
import 'package:achievement/core/services/block_sync_service.dart';
import 'package:achievement/data/model/app_usage_model.dart';

sealed class AppUsageState {}

class AppUsageStateLoading extends AppUsageState {}

class AppUsageStateLoaded extends AppUsageState {
  final List<AppUsageModel> apps;
  final Set<String> watchedPackages;
  final int thresholdMinutes;
  AppUsageStateLoaded(this.apps, this.watchedPackages, this.thresholdMinutes);
}

class AppUsageStatePermissionDenied extends AppUsageState {}

class AppUsageStateError extends AppUsageState {
  final String message;
  AppUsageStateError(this.message);
}

enum AppUsageEvent { load, refresh }

class BlocAppUsage extends BlocBase {
  final StreamController<AppUsageState> _stateController =
      StreamController<AppUsageState>();
  final StreamController<AppUsageEvent> _eventController =
      StreamController<AppUsageEvent>();

  Sink<AppUsageEvent> get inEvent => _eventController.sink;
  Stream<AppUsageState> get outState => _stateController.stream;

  Stream<AppUsageEvent> get _outEvent => _eventController.stream;
  Sink<AppUsageState> get _inState => _stateController.sink;

  Map<String, String> _watchlist = {};
  List<AppUsageModel> _lastApps = [];
  int _thresholdMinutes = 60;

  BlocAppUsage() {
    _outEvent.listen(_handleEvent);
    _init();
  }

  Future<void> _init() async {
    _watchlist = await AppUsageService().loadWatchlist();
    _thresholdMinutes = await BlockSyncService().readThreshold();
    // Sync watchlist to SharedPreferences so the native accessibility service
    // can read it even if the user never toggled an app this session.
    await BlockSyncService().writeBlockList(_watchlist.keys.toList());
    _eventController.add(AppUsageEvent.load);
  }

  @override
  void dispose() {
    _eventController.close();
    _stateController.close();
  }

  void _handleEvent(AppUsageEvent event) {
    switch (event) {
      case AppUsageEvent.load:
      case AppUsageEvent.refresh:
        _handleLoad();
    }
  }

  Future<void> _handleLoad() async {
    _inState.add(AppUsageStateLoading());
    try {
      final service = AppUsageService();
      final hasPermission = await service.hasPermission();
      if (!hasPermission) {
        _inState.add(AppUsageStatePermissionDenied());
        return;
      }
      final apps = await service.fetchTodayUsage();
      _lastApps = apps;
      _inState.add(AppUsageStateLoaded(apps, _watchlist.keys.toSet(), _thresholdMinutes));
    } catch (e) {
      _inState.add(AppUsageStateError(e.toString()));
    }
  }

  Future<void> toggleWatch(String packageName, String appName) async {
    if (_watchlist.containsKey(packageName)) {
      _watchlist.remove(packageName);
    } else {
      _watchlist[packageName] = appName;
    }
    await AppUsageService().saveWatchlist(_watchlist);
    await BlockSyncService().writeBlockList(_watchlist.keys.toList());
    _inState.add(AppUsageStateLoaded(_lastApps, _watchlist.keys.toSet(), _thresholdMinutes));
  }

  Future<void> setThreshold(int minutes) async {
    _thresholdMinutes = minutes;
    await BlockSyncService().writeThreshold(minutes);
    _inState.add(AppUsageStateLoaded(_lastApps, _watchlist.keys.toSet(), _thresholdMinutes));
  }

}
