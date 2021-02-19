import 'dart:convert';

class AchievementModel {
  int id;
  String header;
  String description;
  String imagePath;
  DateTime createDate;
  DateTime finishDate;
  List<int> remindIds;

  AchievementModel(this.id, this.header, this.description, this.imagePath,
      this.createDate, this.finishDate, this.remindIds);

  AchievementModel.fromMap(Map<String, dynamic> achievement) {
    id = achievement['id'] as int;
    header = achievement['header'] as String;
    description = achievement['description'] as String;
    imagePath = achievement['image_path'] as String;
    createDate =
        DateTime.fromMillisecondsSinceEpoch(achievement['create_date'] as int);
    finishDate =
        DateTime.fromMillisecondsSinceEpoch(achievement['finish_date'] as int);
    List<dynamic> ids =
        jsonDecode(achievement['remind_ids'] as String) as List<dynamic>;
    remindIds = ids.cast<int>();
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['id'] = id;
    map['header'] = header;
    map['description'] = description;
    map['image_path'] = imagePath;
    map['create_date'] = createDate.millisecondsSinceEpoch;
    map['finish_date'] = finishDate.millisecondsSinceEpoch;
    map['remind_ids'] = jsonEncode(remindIds);
    return map;
  }
}
