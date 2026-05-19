class BlockedAppModel {
  final int id;
  final String packageName;
  final String appName;
  final DateTime addedDate;

  const BlockedAppModel({
    required this.id,
    required this.packageName,
    required this.appName,
    required this.addedDate,
  });

  factory BlockedAppModel.fromJson(Map<String, dynamic> map) => BlockedAppModel(
        id: map['id'] as int,
        packageName: map['package_name'] as String,
        appName: map['app_name'] as String,
        addedDate: DateTime.fromMillisecondsSinceEpoch(map['added_date'] as int),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'package_name': packageName,
        'app_name': appName,
        'added_date': addedDate.millisecondsSinceEpoch,
      };
}
