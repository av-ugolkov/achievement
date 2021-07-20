class ProgressEntity {
  late int id;
  late Map<String, ProgressDescription> progressDescription;

  ProgressEntity({required this.id, required this.progressDescription});
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
