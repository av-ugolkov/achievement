import 'package:achievement/core/enums.dart';
import 'package:achievement/data/model/achievement_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AchievementModel', () {
    test('fromJson(toJson()) round-trips all fields', () {
      final model = AchievementModel(
        id: 1,
        header: 'Test Achievement',
        createDate: DateTime(2024, 1, 15),
        finishDate: DateTime(2024, 12, 31),
        state: AchievementState.finished,
        description: 'Test description',
        imagePath: '/path/to/image.png',
        remindIds: [2, 3, 5],
        progressId: 7,
      );

      final result = AchievementModel.fromJson(model.toJson());

      expect(result.id, model.id);
      expect(result.header, model.header);
      expect(result.createDate, model.createDate);
      expect(result.finishDate, model.finishDate);
      expect(result.state, model.state);
      expect(result.description, model.description);
      expect(result.imagePath, model.imagePath);
      expect(result.remindIds, model.remindIds);
      expect(result.progressId, model.progressId);
    });

    test('fromJson(toJson()) round-trips with empty remindIds and defaults', () {
      final model = AchievementModel(
        id: 2,
        header: 'Minimal',
        createDate: DateTime(2024, 3, 1),
        finishDate: DateTime(2024, 6, 1),
        remindIds: [],
      );

      final result = AchievementModel.fromJson(model.toJson());

      expect(result.remindIds, isEmpty);
      expect(result.progressId, -1);
      expect(result.state, AchievementState.active);
      expect(result.description, '');
      expect(result.imagePath, '');
    });

    test('empty factory produces sentinel id -1', () {
      final model = AchievementModel.empty;
      expect(model.id, -1);
      expect(model.header, '');
    });
  });
}
