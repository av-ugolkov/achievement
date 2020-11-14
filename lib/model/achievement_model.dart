class AchievementModel {
  int id;
  String header;
  String description;
  String imagePath;
  DateTime createDate;
  DateTime finishDate;
  bool isRemind;

  AchievementModel(this.id, this.header, this.description, this.imagePath,
      this.createDate, this.finishDate, this.isRemind);

  AchievementModel.fromMap(Map<String, dynamic> achievement) {
    id = achievement['id'];
    header = achievement['header'];
    description = achievement['description'];
    imagePath = achievement['image_path'];
    createDate =
        DateTime.fromMillisecondsSinceEpoch(achievement['create_date']);
    finishDate =
        DateTime.fromMillisecondsSinceEpoch(achievement['finish_date']);
    isRemind = achievement['is_remind'] == 1;
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['id'] = id;
    map['header'] = header;
    map['description'] = description;
    map['image_path'] = imagePath;
    map['create_date'] = createDate.millisecondsSinceEpoch;
    map['finish_date'] = finishDate.millisecondsSinceEpoch;
    map['is_remind'] = isRemind ? 1 : 0;
    return map;
  }
}
