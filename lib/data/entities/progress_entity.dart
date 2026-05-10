class ProgressEntity {
  late int id;
  late Map<String, ProgressDescription> progressDescription;

  ProgressEntity({required this.id, required this.progressDescription});
}

class ProgressDescription {
  late bool isDoAnything;
  late String description;

  ProgressDescription({required this.isDoAnything, required this.description});

  ProgressDescription.fromJson(Map<String, dynamic> map)
      : isDoAnything = map['isDoAnything'] as int == 1,
        description = map['description'] as String;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['isDoAnything'] = isDoAnything ? 1 : 0;
    map['description'] = description;
    return map;
  }
}
