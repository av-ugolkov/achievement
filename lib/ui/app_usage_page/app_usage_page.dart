import 'package:achievement/bloc/bloc_app_usage.dart';
import 'package:achievement/bloc/bloc_provider.dart';
import 'package:achievement/data/model/app_usage_model.dart';
import 'package:achievement/generated/l10n.dart';
import 'package:flutter/material.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<BlocAppUsage>(context);
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
          if (state.apps.isEmpty) {
            return Center(child: Text(S.of(context).appUsageEmpty));
          }
          return ListView.builder(
            itemCount: state.apps.length,
            itemBuilder: (context, index) => _AppTile(model: state.apps[index]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AppTile extends StatelessWidget {
  final AppUsageModel model;
  const _AppTile({required this.model});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildIcon(),
      title: Text(model.appName),
      trailing: Text(_formatMinutes(model.usageMinutes)),
    );
  }

  Widget _buildIcon() {
    final icon = model.icon;
    if (icon != null && icon.isNotEmpty) {
      return Image.memory(icon, width: 40, height: 40);
    }
    return const Icon(Icons.apps, size: 40);
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) return '$hours ч $mins м';
    return '$mins м';
  }
}
