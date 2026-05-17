import 'dart:typed_data';

class AppUsageModel {
  final String appName;
  final String packageName;
  final Uint8List? icon;
  final int usageMinutes;

  const AppUsageModel({
    required this.appName,
    required this.packageName,
    required this.usageMinutes,
    this.icon,
  });
}
