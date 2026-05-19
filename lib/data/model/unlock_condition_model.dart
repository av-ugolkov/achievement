import 'package:achievement/core/services/block_sync_service.dart';

enum UnlockConditionType { timeInApp }

sealed class UnlockConditionModel {
  final int id;
  final UnlockConditionType type;
  const UnlockConditionModel({required this.id, required this.type});

  factory UnlockConditionModel.fromMap(Map<String, dynamic> map) {
    final type = UnlockConditionType.values[map['condition_type'] as int];
    return switch (type) {
      UnlockConditionType.timeInApp => TimeInAppCondition.fromMap(map),
    };
  }

  Map<String, dynamic> toMap();

  Future<bool> isSatisfied();

  Future<void> syncToNative(BlockSyncService sync);
}

class TimeInAppCondition extends UnlockConditionModel {
  final String targetPackage;
  final String targetAppName;
  final int thresholdMinutes;

  const TimeInAppCondition({
    required super.id,
    required this.targetPackage,
    required this.targetAppName,
    required this.thresholdMinutes,
  }) : super(type: UnlockConditionType.timeInApp);

  factory TimeInAppCondition.fromMap(Map<String, dynamic> map) =>
      TimeInAppCondition(
        id: map['id'] as int,
        targetPackage: map['target_package'] as String,
        targetAppName: map['target_app_name'] as String,
        thresholdMinutes: map['threshold_mins'] as int,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'condition_type': type.index,
        'target_package': targetPackage,
        'target_app_name': targetAppName,
        'threshold_mins': thresholdMinutes,
        'is_active': 1,
      };

  @override
  Future<bool> isSatisfied() async {
    final sync = BlockSyncService();
    final usage = await sync.readTargetUsage();
    return usage >= thresholdMinutes;
  }

  @override
  Future<void> syncToNative(BlockSyncService sync) async {
    await sync.writeUnlockConditionType(type.index);
    await sync.writeTargetPackage(targetPackage);
    await sync.writeThreshold(thresholdMinutes);
  }
}
