import 'package:achievement/core/services/block_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlockerPage extends StatefulWidget {
  const BlockerPage({super.key});

  @override
  State<BlockerPage> createState() => _BlockerPageState();
}

class _BlockerPageState extends State<BlockerPage> {
  int _usageMinutes = 0;
  int _thresholdMinutes = 60;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final sync = BlockSyncService();
    final usage = await sync.readAchievementUsage();
    final threshold = await sync.readThreshold();
    if (!mounted) return;
    setState(() {
      _usageMinutes = usage;
      _thresholdMinutes = threshold;
    });
  }

  @override
  Widget build(BuildContext context) {
    final blockedPackage =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';
    final progress = _thresholdMinutes > 0
        ? (_usageMinutes / _thresholdMinutes).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (_thresholdMinutes - _usageMinutes).clamp(0, _thresholdMinutes);

    return Scaffold(
      body: SafeArea(
        child: Padding(
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
              Text('$_usageMinutes / $_thresholdMinutes мин в Achievement'),
              const SizedBox(height: 4),
              Text(
                'Осталось ещё $remaining мин',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              const Text(
                'Сначала поработай над своими целями!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('На главную'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
