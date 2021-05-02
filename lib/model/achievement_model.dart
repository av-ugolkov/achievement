import 'dart:convert';
import 'package:achievement/core/enums.dart';

class AchievementModel {
  static AchievementModel get empty => AchievementModel(
        id: -1,
        header: '',
        createDate: DateTime(0),
        finishDate: DateTime(0),
      );

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

  late int _progressId;
  int get progressId => _progressId;
  set progressId(int progressId) {
    if (_progressId == progressId) return;
    _progressId = progressId;
  }

  late AchievementState _state;
  AchievementState get state => _state;
  set state(AchievementState state) {
    if (_state == state) return;
    _state = state;
  }

  AchievementModel({
    required int id,
    required String header,
    required DateTime createDate,
    required DateTime finishDate,
    AchievementState state = AchievementState.active,
    String description = '',
    String imagePath = '',
    List<int>? remindIds,
    int? progressId,
  })  : _id = id,
        _header = header,
        _createDate = createDate,
        _finishDate = finishDate,
        _state = state,
        _description = description,
        _imagePath = imagePath,
        _remindIds = remindIds ?? [],
        _progressId = progressId ?? -1;

  factory AchievementModel.fromJson(Map<String, dynamic> map) {
    var ids = jsonDecode(map['remind_ids'] as String) as List<dynamic>;
    var remindIds = ids.cast<int>();

    return AchievementModel(
      id: map['id'] as int,
      header: map['header'] as String,
      createDate:
          DateTime.fromMillisecondsSinceEpoch(map['create_date'] as int),
      finishDate:
          DateTime.fromMillisecondsSinceEpoch(map['finish_date'] as int),
      state: AchievementState.values[map['state'] as int],
      description: map['description'] as String,
      imagePath: map['image_path'] as String,
      remindIds: remindIds,
      progressId: map['progress_ids'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['state'] = state.index;
    map['header'] = header;
    map['description'] = description;
    map['image_path'] = imagePath;
    map['create_date'] = createDate.millisecondsSinceEpoch;
    map['finish_date'] = finishDate.millisecondsSinceEpoch;
    map['remind_ids'] = jsonEncode(remindIds);
    map['progress_ids'] = progressId;
    return map;
  }
}
