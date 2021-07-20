import 'dart:convert';
import 'package:achievement/core/enums.dart';
import 'package:achievement/data/entities/remind_entity.dart';

class RemindModel extends RemindEntity {
  static RemindModel get empty => RemindModel(
      id: -1,
      remindDateTime: RemindDateTime(
        year: 0,
        month: 0,
        day: 0,
        hour: 0,
        minute: 0,
      ));

  RemindModel({
    required int id,
    required RemindDateTime remindDateTime,
    TypeRepition typeRepition = TypeRepition.none,
  }) : super(
          id: id,
          typeRepition: typeRepition,
          remindDateTime: remindDateTime,
        );

  factory RemindModel.fromJson(Map<String, dynamic> map) {
    return RemindModel(
        id: map['id'] as int,
        remindDateTime: RemindDateTime.fromJson(
            jsonDecode(map['dateTime'] as String) as Map<String, dynamic>),
        typeRepition: TypeRepition.values[map['typeRepition'] as int]);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['typeRepition'] = typeRepition.index;
    map['dateTime'] = jsonEncode(remindDateTime.toJson());
    return map;
  }
}
