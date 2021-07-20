import 'dart:convert';
import 'package:achievement/core/enums.dart';
import 'package:achievement/data/entities/achievement_entity.dart';

class AchievementModel extends AchievementEntity {
  static AchievementModel get empty => AchievementModel(
        id: -1,
        header: '',
        createDate: DateTime(0),
        finishDate: DateTime(0),
      );

  AchievementModel({
    required int id,
    required String header,
    required DateTime createDate,
    required DateTime finishDate,
    AchievementState state = AchievementState.active,
    String description = '',
    String imagePath = '',
    List<int> remindIds = const [],
    int progressId = -1,
  }) : super(
            id: id,
            header: header,
            createDate: createDate,
            finishDate: finishDate,
            state: state,
            description: description,
            imagePath: imagePath,
            remindIds: remindIds,
            progressId: progressId);

  factory AchievementModel.fromJson(Map<String, dynamic> map) {
    var ids = jsonDecode(map['remind_ids'] as String) as List<dynamic>;
    var remindIds = ids.cast<int>();

    return AchievementModel(
      id: map['id'] as int,
      header: map['header'] as String,
      createDate:
          DateTime.fromMillisecondsSinceEpoch(map['create_date'] as int),
      finishDate:
          DateTime.fromMillisecondsSinceEpoch(map['finish_date'] as int),
      state: AchievementState.values[map['state'] as int],
      description: map['description'] as String,
      imagePath: map['image_path'] as String,
      remindIds: remindIds,
      progressId: map['progress_ids'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['state'] = state.index;
    map['header'] = header;
    map['description'] = description;
    map['image_path'] = imagePath;
    map['create_date'] = createDate.millisecondsSinceEpoch;
    map['finish_date'] = finishDate.millisecondsSinceEpoch;
    map['remind_ids'] = jsonEncode(remindIds);
    map['progress_ids'] = progressId;
    return map;
  }

  void setData({
    int? id,
    String? header,
    DateTime? createDate,
    DateTime? finishDate,
    AchievementState? state,
    String? description,
    String? imagePath,
    List<int>? remindIds,
    int? progressId,
  }) {
    super.id = id ?? super.id;
    super.header = header ?? super.header;
    super.description = description ?? super.description;
    super.createDate = createDate ?? super.createDate;
    super.finishDate = finishDate ?? super.finishDate;
    super.state = state ?? super.state;
    super.imagePath = imagePath ?? super.imagePath;
    super.remindIds = remindIds ?? super.remindIds;
    super.progressId = progressId ?? super.progressId;
  }

  void setModel(AchievementModel model) {
    setData(
      id: model.id,
      header: model.header,
      createDate: model.createDate,
      finishDate: model.finishDate,
      state: model.state,
      description: model.description,
      imagePath: model.imagePath,
      remindIds: model.remindIds,
      progressId: model.progressId,
    );
  }
}
