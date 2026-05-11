import 'package:achievement/core/enums.dart';
import 'package:achievement/data/entities/remind_entity.dart';
import 'package:achievement/data/model/remind_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemindModel', () {
    test('fromJson(toJson()) round-trips all fields', () {
      final model = RemindModel(
        id: 1,
        remindDateTime: RemindDateTime(
          year: 2024,
          month: 6,
          day: 15,
          hour: 9,
          minute: 30,
        ),
        typeRepetition: TypeRepetition.day,
      );

      final result = RemindModel.fromJson(model.toJson());

      expect(result.id, 1);
      expect(result.typeRepetition, TypeRepetition.day);
      expect(result.remindDateTime.year, 2024);
      expect(result.remindDateTime.month, 6);
      expect(result.remindDateTime.day, 15);
      expect(result.remindDateTime.hour, 9);
      expect(result.remindDateTime.minute, 30);
    });

    test('fromJson(toJson()) round-trips with TypeRepetition.week', () {
      final model = RemindModel(
        id: 2,
        remindDateTime:
            RemindDateTime(year: 2024, month: 1, day: 1, hour: 0, minute: 0),
        typeRepetition: TypeRepetition.week,
      );

      final result = RemindModel.fromJson(model.toJson());

      expect(result.typeRepetition, TypeRepetition.week);
      expect(result.remindDateTime.minute, 0);
    });

    test('empty factory produces sentinel id -1', () {
      expect(RemindModel.empty.id, -1);
    });
  });
}
