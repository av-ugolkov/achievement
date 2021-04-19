import 'dart:convert';

class ProgressModel {
  late int id;
  late Map<String, ProgressDescription> progressDescription;

  static ProgressModel get empty =>
      ProgressModel(id: -1, progressDescription: {});

  ProgressModel({required this.id, required this.progressDescription});

  ProgressModel.fromMap(Map<String, dynamic> map) : id = map['id'] as int {
    progressDescription = jsonDecode(map['descriptionProgress'] as String)
        as Map<String, ProgressDescription>;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    var newP = <String, String>{};
    for (var entity in progressDescription.entries) {
      newP = {entity.key: jsonEncode(entity.value)};
    }
    map['progressDescription'] = jsonEncode(newP);
    return map;
  }
}

class ProgressDescription {
  late bool isDoAnythink;
  late String description;

  ProgressDescription({required this.isDoAnythink, required this.description});

  ProgressDescription.fromJson(Map<String, dynamic> map)
      : isDoAnythink = map['isDoAnythink'] as int == 1,
        description = map['description'] as String;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['isDoAnythink'] = isDoAnythink ? 1 : 0;
    map['description'] = description;
    return map;
  }
}
