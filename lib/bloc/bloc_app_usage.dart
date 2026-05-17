import 'dart:async';
import 'package:achievement/bloc/bloc_base.dart';
import 'package:achievement/core/services/app_usage_service.dart';
import 'package:achievement/data/model/app_usage_model.dart';

sealed class AppUsageState {}

class AppUsageStateLoading extends AppUsageState {}

class AppUsageStateLoaded extends AppUsageState {
  final List<AppUsageModel> apps;
  AppUsageStateLoaded(this.apps);
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

  BlocAppUsage() {
    _outEvent.listen(_handleEvent);
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
      _inState.add(AppUsageStateLoaded(apps));
    } catch (e) {
      _inState.add(AppUsageStateError(e.toString()));
    }
  }
}
