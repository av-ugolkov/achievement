import 'dart:async';

import 'package:achievement/bloc/bloc_app_usage.dart';
import 'package:achievement/bloc/bloc_provider.dart';
import 'package:achievement/bloc/bloc_unlock_progress.dart';
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
  late BlocUnlockProgress _progressBloc;

  @override
  void initState() {
    super.initState();
    _progressBloc = BlocUnlockProgress();
  }

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
    _progressBloc.dispose();
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
    _progressBloc.inEvent.add(UnlockProgressEvent.refresh);
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
                        onPressed: () async {
                          await Navigator.pushNamed(
                              context, routeConditionConfigPage);
                          _progressBloc.inEvent.add(UnlockProgressEvent.refresh);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _UnlockConditionCard(bloc: _progressBloc),
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

class _UnlockConditionCard extends StatelessWidget {
  final BlocUnlockProgress bloc;

  const _UnlockConditionCard({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UnlockProgressState>(
      stream: bloc.outState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state is UnlockProgressTracking) {
          if (!state.hasCondition) return _buildEmpty(context);
          if (state.unlocked) return _buildUnlocked(state);
          return _buildInProgress(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed(routeConditionConfigPage);
        bloc.inEvent.add(UnlockProgressEvent.refresh);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock_open, color: Colors.grey, size: 20),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Условие разблокировки не задано',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Нажми «Условие» чтобы настроить',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInProgress(UnlockProgressTracking state) {
    final progress = state.thresholdMinutes == 0
        ? 1.0
        : (state.usageMinutes / state.thresholdMinutes).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x146366F1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x336366F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.targetAppName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      'Проведи ${state.thresholdMinutes} мин для разблокировки',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                '${state.usageMinutes}/${state.thresholdMinutes} м',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0x33E0E7FF),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            borderRadius: BorderRadius.circular(3),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildUnlocked(UnlockProgressTracking state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1410B981),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x4D10B981)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              color: Color(0xFF10B981), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Заблокированные приложения разблокированы',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065F46),
                      fontSize: 12),
                ),
                Text(
                  '${state.targetAppName} · ${state.thresholdMinutes} мин засчитано',
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF6EE7B7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
