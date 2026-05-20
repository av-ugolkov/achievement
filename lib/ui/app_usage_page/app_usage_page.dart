import 'dart:async';

import 'package:achievement/bloc/bloc_app_usage.dart';
import 'package:achievement/bloc/bloc_provider.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/data/model/app_usage_model.dart';
import 'package:achievement/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _blockerChannel = MethodChannel('com.ugolkov.achievement/blocker');

class AppUsagePage extends StatelessWidget {
  const AppUsagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocAppUsage>(
      bloc: BlocAppUsage(),
      child: const _AppUsageBody(),
    );
  }
}

class _AppUsageBody extends StatefulWidget {
  const _AppUsageBody();

  @override
  State<_AppUsageBody> createState() => _AppUsageBodyState();
}

class _AppUsageBodyState extends State<_AppUsageBody> {
  late BlocAppUsage _bloc;
  Timer? _watchTimer;
  bool _accessibilityEnabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<BlocAppUsage>(context);
    _watchTimer ??= Timer.periodic(const Duration(minutes: 1), _onTimerTick);
    _checkAccessibility();
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAccessibility() async {
    try {
      final enabled = await _blockerChannel
          .invokeMethod<bool>('isAccessibilityEnabled') ?? false;
      if (mounted) setState(() => _accessibilityEnabled = enabled);
    } catch (_) {}
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      await _blockerChannel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  Future<void> _onTimerTick(Timer _) async {
    _checkAccessibility();
    final underThreshold = await _bloc.checkWatchedUnderThreshold();
    if (!mounted || underThreshold.isEmpty) return;
    _showWatchAlert(underThreshold);
  }

  void _showWatchAlert(List<AppUsageModel> apps) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Наблюдаемые приложения'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: apps
                .map(
                  (a) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${a.appName}: ${_formatMinutes(a.usageMinutes)}',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUsageState>(
      stream: _bloc.outState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == null || state is AppUsageStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AppUsageStatePermissionDenied) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                S.of(context).appUsagePermissionDenied,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (state is AppUsageStateError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message, textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => _bloc.inEvent.add(AppUsageEvent.refresh),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }
        if (state is AppUsageStateLoaded) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.block),
                        label: const Text('Заблок. приложения'),
                        onPressed: () =>
                            Navigator.pushNamed(context, routeAppPickerPage),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.lock_open),
                        label: const Text('Условие'),
                        onPressed: () => Navigator.pushNamed(
                            context, routeConditionConfigPage),
                      ),
                    ),
                  ],
                ),
              ),
              _AccessibilityBanner(
                enabled: _accessibilityEnabled,
                onEnable: _openAccessibilitySettings,
              ),
              if (state.apps.isEmpty)
                Expanded(
                  child: Center(child: Text(S.of(context).appUsageEmpty)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: state.apps.length,
                    itemBuilder: (context, index) {
                      final model = state.apps[index];
                      return _AppTile(
                        model: model,
                        isWatched:
                            state.watchedPackages.contains(model.packageName),
                        onToggleWatch: () =>
                            _bloc.toggleWatch(model.packageName, model.appName),
                      );
                    },
                  ),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AccessibilityBanner extends StatelessWidget {
  final bool enabled;
  final VoidCallback onEnable;

  const _AccessibilityBanner({required this.enabled, required this.onEnable});

  @override
  Widget build(BuildContext context) {
    if (enabled) return const SizedBox.shrink();
    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      content: const Text(
        'Включи сервис специальных возможностей для блокировки приложений',
      ),
      actions: [
        TextButton(
          onPressed: onEnable,
          child: const Text('Включить'),
        ),
      ],
    );
  }
}

class _AppTile extends StatelessWidget {
  final AppUsageModel model;
  final bool isWatched;
  final VoidCallback onToggleWatch;

  const _AppTile({
    required this.model,
    required this.isWatched,
    required this.onToggleWatch,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildIcon(),
      title: Text(model.appName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_formatMinutes(model.usageMinutes)),
          IconButton(
            icon: Icon(
              isWatched ? Icons.block : Icons.block_outlined,
              color: isWatched ? Colors.redAccent : null,
            ),
            tooltip: isWatched ? 'Снять блокировку' : 'Заблокировать',
            onPressed: onToggleWatch,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    final icon = model.icon;
    if (icon != null && icon.isNotEmpty) {
      return Image.memory(icon, width: 40, height: 40);
    }
    return const Icon(Icons.apps, size: 40);
  }
}

String _formatMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours > 0) return '$hours ч $mins м';
  return '$mins м';
}
