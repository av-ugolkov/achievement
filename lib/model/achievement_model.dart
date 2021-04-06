import 'dart:convert';
import 'package:achievement/enums.dart';

class AchievementModel {
  late int _id;
  int get id => _id;
  set id(int id) {
    if (_id == id) return;
    _id = id;
  }

  late String _header;
  String get header => _header;
  set header(String header) {
    if (_header == header) return;
    _header = header;
  }

  late String _description;
  String get description => _description;
  set description(String description) {
    if (_description == description) return;
    _description = description;
  }

  late String _imagePath;
  String get imagePath => _imagePath;
  set imagePath(String imagePath) {
    if (_imagePath == imagePath) return;
    _imagePath = imagePath;
  }

  late DateTime _createDate;
  DateTime get createDate => _createDate;
  set createDate(DateTime createDate) {
    if (_createDate == createDate) return;
    _createDate = createDate;
  }

  late DateTime _finishDate;
  DateTime get finishDate => _finishDate;
  set finishDate(DateTime finishDate) {
    if (_finishDate == finishDate) return;
    _finishDate = finishDate;
  }

  late List<int> _remindIds;
  List<int> get remindIds => _remindIds;
  set remindIds(List<int> remindIds) {
    if (_remindIds == remindIds) return;
    _remindIds = remindIds;
  }

  late AchievementState _state;
  AchievementState get state => _state;
  set state(AchievementState state) {
    if (_state == state) return;
    _state = state;
  }

  AchievementModel(
    int id,
    String header,
    DateTime createDate,
    DateTime finishDate, {
    String description = '',
    String imagePath = '',
    List<int>? remindIds,
    AchievementState state = AchievementState.active,
  })  : _id = id,
        _header = header,
        _description = description,
        _imagePath = imagePath,
        _createDate = createDate,
        _finishDate = finishDate,
        _remindIds = remindIds ?? [],
        _state = state;

  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    var ids = jsonDecode(map['remind_ids'] as String) as List<dynamic>;
    var remindIds = ids.cast<int>();

    return AchievementModel(
      map['id'] as int,
      map['header'] as String,
      DateTime.fromMillisecondsSinceEpoch(map['create_date'] as int),
      DateTime.fromMillisecondsSinceEpoch(map['finish_date'] as int),
      description: map['description'] as String,
      imagePath: map['image_path'] as String,
      remindIds: remindIds,
      state: AchievementState.values[map['state'] as int],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['header'] = header;
    map['description'] = description;
    map['image_path'] = imagePath;
    map['create_date'] = createDate.millisecondsSinceEpoch;
    map['finish_date'] = finishDate.millisecondsSinceEpoch;
    map['remind_ids'] = jsonEncode(remindIds);
    map['state'] = state.index;
    return map;
  }
}
