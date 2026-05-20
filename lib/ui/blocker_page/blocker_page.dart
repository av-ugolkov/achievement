import 'dart:async';

import 'package:achievement/bloc/bloc_provider.dart';
import 'package:achievement/bloc/bloc_unlock_progress.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlockerPage extends StatelessWidget {
  const BlockerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocUnlockProgress>(
      bloc: BlocUnlockProgress(),
      child: const _BlockerBody(),
    );
  }
}

class _BlockerBody extends StatefulWidget {
  const _BlockerBody();

  @override
  State<_BlockerBody> createState() => _BlockerBodyState();
}

class _BlockerBodyState extends State<_BlockerBody> {
  late BlocUnlockProgress _bloc;
  Timer? _refreshTimer;
  bool _navigatedToSuccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<BlocUnlockProgress>(context);
    _refreshTimer ??= Timer.periodic(
      const Duration(minutes: 1),
      (_) => _bloc.inEvent.add(UnlockProgressEvent.refresh),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _onStateChanged(UnlockProgressState state) {
    if (state is UnlockProgressTracking &&
        state.unlocked &&
        !_navigatedToSuccess &&
        mounted) {
      _navigatedToSuccess = true;
      Navigator.of(context).pushReplacementNamed(routeUnlockSuccessPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockedPackage =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<UnlockProgressState>(
          stream: _bloc.outState,
          builder: (context, snapshot) {
            final state = snapshot.data;
            _onStateChanged(state ?? UnlockProgressLoading());

            if (state == null || state is UnlockProgressLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UnlockProgressTracking) {
              final progress = state.thresholdMinutes > 0
                  ? (state.usageMinutes / state.thresholdMinutes)
                      .clamp(0.0, 1.0)
                  : 0.0;
              final remaining =
                  (state.thresholdMinutes - state.usageMinutes)
                      .clamp(0, state.thresholdMinutes);

              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 24),
                    Text(
                      'Приложение заблокировано',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      blockedPackage,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Используй ${state.targetAppName} ещё $remaining мин для разблокировки',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('${state.usageMinutes} / ${state.thresholdMinutes} мин'),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => SystemNavigator.pop(),
                      child: const Text('На главную'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
