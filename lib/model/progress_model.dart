import 'dart:convert';

class ProgressModel {
  late int id;
  late List<DescriptionProgress> descriptionProgress;

  static ProgressModel get empty =>
      ProgressModel(id: -1, descriptionProgress: []);

  ProgressModel({required this.id, required this.descriptionProgress});

  ProgressModel.fromMap(Map<String, dynamic> map) : id = map['id'] as int {
    var list = DescriptionProgress.fromMap(
        jsonDecode(map['descriptionProgress'] as String)
            as Map<String, dynamic>);
    descriptionProgress = [];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['descriptionProgress'] = descriptionProgress;
    return map;
  }
}

class DescriptionProgress {
  late DateTime date;
  late bool isDoAnythink;
  late String description;

  DescriptionProgress(
      {required this.date,
      required this.isDoAnythink,
      required this.description});

  DescriptionProgress.fromMap(Map<String, dynamic> map)
      : date = map['date'] as DateTime,
        isDoAnythink = map['isDoAnythink'] as int == 1,
        description = map['description'] as String;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['date'] = date;
    map['isDoAnythink'] = isDoAnythink ? 1 : 0;
    map['description'] = description;
    return map;
  }
}
