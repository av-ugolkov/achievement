import 'dart:typed_data';

import 'package:achievement/bloc/bloc_blocking_config.dart';
import 'package:achievement/bloc/bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

const _kAchievementPackage = 'com.ugolkov.achievement';

class AppPickerPage extends StatelessWidget {
  const AppPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocBlockingConfig>(
      bloc: BlocBlockingConfig(),
      child: const _AppPickerBody(),
    );
  }
}

class _AppPickerBody extends StatefulWidget {
  const _AppPickerBody();

  @override
  State<_AppPickerBody> createState() => _AppPickerBodyState();
}

class _AppPickerBodyState extends State<_AppPickerBody> {
  late BlocBlockingConfig _bloc;
  List<AppInfo> _allApps = [];
  bool _loadingApps = true;
  String _search = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<BlocBlockingConfig>(context);
    if (_loadingApps) _loadApps();
  }

  Future<void> _loadApps() async {
    // excludeSystemApps = false to include all apps, withIcon = true
    final apps = await InstalledApps.getInstalledApps(false, true);
    apps.sort((a, b) => a.name.compareTo(b.name));
    if (!mounted) return;
    setState(() {
      _allApps = apps
          .where((a) => a.packageName != _kAchievementPackage)
          .toList();
      _loadingApps = false;
    });
  }

  List<AppInfo> get _filtered {
    if (_search.isEmpty) return _allApps;
    final q = _search.toLowerCase();
    return _allApps.where((a) => a.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заблокированные приложения')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: StreamBuilder<BlockingConfigState>(
              stream: _bloc.outState,
              builder: (context, snapshot) {
                final state = snapshot.data;
                Set<String> blockedPkgs = {};
                if (state is BlockingConfigLoaded) {
                  blockedPkgs =
                      state.blockedApps.map((a) => a.packageName).toSet();
                }
                if (_loadingApps) {
                  return const Center(child: CircularProgressIndicator());
                }
                final apps = _filtered;
                if (apps.isEmpty) {
                  return const Center(child: Text('Приложения не найдены'));
                }
                return ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final isBlocked = blockedPkgs.contains(app.packageName);
                    return _AppRow(
                      app: app,
                      isBlocked: isBlocked,
                      onToggle: () {
                        if (isBlocked) {
                          _bloc.removeBlockedApp(app.packageName);
                        } else {
                          _bloc.addBlockedApp(app.packageName, app.name);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  final AppInfo app;
  final bool isBlocked;
  final VoidCallback onToggle;

  const _AppRow({
    required this.app,
    required this.isBlocked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildIcon(app.icon),
      title: Text(app.name),
      subtitle: Text(
        app.packageName,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: Icon(
          isBlocked ? Icons.block : Icons.block_outlined,
          color: isBlocked ? Colors.redAccent : null,
        ),
        tooltip: isBlocked ? 'Снять блокировку' : 'Заблокировать',
        onPressed: onToggle,
      ),
    );
  }

  Widget _buildIcon(Uint8List? icon) {
    if (icon != null && icon.isNotEmpty) {
      return Image.memory(icon, width: 40, height: 40);
    }
    return const Icon(Icons.apps, size: 40);
  }
}