import 'dart:convert';
import 'package:achievement/data/entities/progress_entity.dart';

class ProgressModel extends ProgressEntity {
  static ProgressModel get empty =>
      ProgressModel(id: -1, progressDescription: {});

  ProgressModel({
    required int id,
    required Map<String, ProgressDescription> progressDescription,
  }) : super(
          id: id,
          progressDescription: progressDescription,
        );

  factory ProgressModel.fromJson(Map<String, dynamic> map) {
    var mapValue = map['progressDescription'] as String;
    var newP = jsonDecode(mapValue) as Map<String, dynamic>;
    var progressDescription = <String, ProgressDescription>{};
    for (var entity in newP.entries) {
      var value = jsonDecode(entity.value.toString()) as Map<String, dynamic>;
      var progDesc = ProgressDescription.fromJson(value);
      progressDescription.putIfAbsent(entity.key, () => progDesc);
    }
    return ProgressModel(
        id: map['id'] as int, progressDescription: progressDescription);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    var newP = <String, String>{};
    for (var entity in progressDescription.entries) {
      newP.putIfAbsent(entity.key, () => jsonEncode(entity.value));
    }
    map['progressDescription'] = jsonEncode(newP);
    return map;
  }
}
