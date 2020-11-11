class AchievementModel {
  int id;
  String header;
  String description;
  String imagePath;
  DateTime createDate;
  DateTime finishDate;

  AchievementModel(this.id, this.header, this.description, this.imagePath,
      this.createDate, this.finishDate);

  AchievementModel.fromMap(Map<String, dynamic> achievement) {
    id = achievement['id'];
    header = achievement['header'];
    description = achievement['description'];
    imagePath = achievement['image_path'];
    createDate =
        DateTime.fromMillisecondsSinceEpoch(achievement['create_date']);
    finishDate =
        DateTime.fromMillisecondsSinceEpoch(achievement['finish_date']);
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['id'] = id;
    map['header'] = header;
    map['description'] = description;
    map['image_path'] = imagePath;
    map['create_date'] = createDate.millisecondsSinceEpoch;
    map['finish_date'] = finishDate.millisecondsSinceEpoch;
    return map;
  }
}
