// ignore_for_file: deprecated_member_use
import 'dart:typed_data';

import 'package:achievement/bloc/bloc_blocking_config.dart';
import 'package:achievement/bloc/bloc_provider.dart';
import 'package:achievement/core/services/app_usage_service.dart';
import 'package:achievement/data/model/unlock_condition_model.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class ConditionConfigPage extends StatelessWidget {
  const ConditionConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocBlockingConfig>(
      bloc: BlocBlockingConfig(),
      child: const _ConditionConfigBody(),
    );
  }
}

class _ConditionConfigBody extends StatefulWidget {
  const _ConditionConfigBody();

  @override
  State<_ConditionConfigBody> createState() => _ConditionConfigBodyState();
}

class _ConditionConfigBodyState extends State<_ConditionConfigBody> {
  late BlocBlockingConfig _bloc;
  String? _targetPackage;
  String? _targetAppName;
  Uint8List? _targetIcon;
  int _thresholdMinutes = 60;
  bool _initialized = false;
  BlockingConfigState? _currentState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<BlocBlockingConfig>(context);
    if (!_initialized) {
      _initialized = true;
      _loadInitialCondition();
    }
  }

  Future<void> _loadInitialCondition() async {
    _bloc.outState.listen((state) {
      if (!mounted) return;
      setState(() => _currentState = state);
      if (state is BlockingConfigLoaded && _targetPackage == null) {
        final condition = state.activeCondition;
        if (condition is TimeInAppCondition) {
          setState(() {
            _targetPackage = condition.targetPackage;
            _targetAppName = condition.targetAppName;
            _thresholdMinutes = condition.thresholdMinutes;
          });
        }
      }
    });
  }

  Future<void> _pickTargetApp() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AppPickerSheet(
        onSelected: (pkg, name, icon) {
          setState(() {
            _targetPackage = pkg;
            _targetAppName = name;
            _targetIcon = icon;
          });
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Future<void> _clearCondition() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сбросить условие?'),
        content: const Text('Условие разблокировки будет удалено.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _bloc.clearUnlockCondition();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    if (_targetPackage == null || _targetAppName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите целевое приложение')),
      );
      return;
    }
    final condition = TimeInAppCondition(
      id: 0,
      targetPackage: _targetPackage!,
      targetAppName: _targetAppName!,
      thresholdMinutes: _thresholdMinutes,
    );
    await _bloc.setUnlockCondition(condition);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Условие разблокировки'),
        actions: [
          if (_currentState is BlockingConfigLoaded &&
              (_currentState as BlockingConfigLoaded).activeCondition != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Сбросить условие',
              onPressed: _clearCondition,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Condition type
          const Text('Тип условия',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RadioListTile<int>(
            value: 0,
            groupValue: 0,
            title: const Text('Проведи время в приложении'),
            onChanged: (_) {},
          ),
          RadioListTile<int>(
            value: 1,
            groupValue: 0,
            title: const Text('Время суток'),
            subtitle: const Text('Скоро'),
            onChanged: null, // disabled
          ),
          const Divider(height: 32),

          // Target app
          const Text('Целевое приложение',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _targetIcon != null && _targetIcon!.isNotEmpty
                ? Image.memory(_targetIcon!, width: 40, height: 40)
                : const Icon(Icons.apps, size: 40),
            title: Text(_targetAppName ?? 'Не выбрано'),
            subtitle: _targetPackage != null ? Text(_targetPackage!) : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickTargetApp,
          ),
          const Divider(height: 32),

          // Threshold
          const Text('Необходимое время',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _thresholdMinutes.toDouble(),
                  min: 5,
                  max: 180,
                  divisions: 35,
                  label: '$_thresholdMinutes мин',
                  onChanged: (v) =>
                      setState(() => _thresholdMinutes = v.round()),
                ),
              ),
              SizedBox(
                width: 60,
                child: Text('$_thresholdMinutes мин',
                    textAlign: TextAlign.center),
              ),
            ],
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _save,
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

class _AppPickerSheet extends StatefulWidget {
  final void Function(String pkg, String name, Uint8List? icon) onSelected;

  const _AppPickerSheet({
    required this.onSelected,
  });

  @override
  State<_AppPickerSheet> createState() => _AppPickerSheetState();
}

class _AppPickerSheetState extends State<_AppPickerSheet> {
  List<AppInfo> _apps = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final launchable = await AppUsageService.getLaunchablePackages();
    final allApps = await InstalledApps.getInstalledApps(false, true);
    final apps = allApps
        .where((a) =>
            a.packageName != 'com.ugolkov.achievement' &&
            launchable.contains(a.packageName))
        .toList();
    apps.sort((a, b) => a.name.compareTo(b.name));
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _loading = false;
    });
  }

  List<AppInfo> get _filtered {
    if (_search.isEmpty) return _apps;
    final q = _search.toLowerCase();
    return _apps.where((a) => a.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollController,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final app = _filtered[i];
                      return ListTile(
                        leading: app.icon != null && app.icon!.isNotEmpty
                            ? Image.memory(app.icon!, width: 40, height: 40)
                            : const Icon(Icons.apps, size: 40),
                        title: Text(app.name),
                        onTap: () =>
                            widget.onSelected(app.packageName, app.name, app.icon),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
