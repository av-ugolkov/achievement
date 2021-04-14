import 'dart:convert';

class ProgressModel {
  late int id;
  late Map<DateTime, ProgressDescription> progressDescription;

  static ProgressModel get empty =>
      ProgressModel(id: -1, progressDescription: {});

  ProgressModel({required this.id, required this.progressDescription});

  ProgressModel.fromMap(Map<String, dynamic> map) : id = map['id'] as int {
    progressDescription = jsonDecode(map['descriptionProgress'] as String)
        as Map<DateTime, ProgressDescription>;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['progressDescription'] = progressDescription;
    return map;
  }
}

class ProgressDescription {
  late bool isDoAnythink;
  late String description;

  ProgressDescription({required this.isDoAnythink, required this.description});

  ProgressDescription.fromMap(Map<String, dynamic> map)
      : isDoAnythink = map['isDoAnythink'] as int == 1,
        description = map['description'] as String;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['isDoAnythink'] = isDoAnythink ? 1 : 0;
    map['description'] = description;
    return map;
  }
}
