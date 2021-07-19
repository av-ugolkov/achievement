import 'package:achievement/core/enums.dart';

class AchievementEntity {
  late int id;
  late String header;
  late String description;
  late String imagePath;
  late DateTime createDate;
  late DateTime finishDate;
  late List<int> remindIds;
  late int progressId;
  late AchievementState state;

  AchievementEntity({
    required int id,
    required String header,
    required DateTime createDate,
    required DateTime finishDate,
    AchievementState state = AchievementState.active,
    String description = '',
    String imagePath = '',
    List<int>? remindIds,
    int? progressId,
  });
}
