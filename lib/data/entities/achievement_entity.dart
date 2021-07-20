import 'package:achievement/core/enums.dart';

class AchievementEntity {
  late int id;
  late String header;
  late String description;
  late String imagePath;
  late DateTime createDate;
  late DateTime finishDate;
  late AchievementState state;
  late List<int> remindIds;
  late int progressId;

  AchievementEntity({
    required this.id,
    required this.header,
    required this.createDate,
    required this.finishDate,
    this.state = AchievementState.active,
    this.description = '',
    this.imagePath = '',
    this.remindIds = const [],
    this.progressId = -1,
  });
}
