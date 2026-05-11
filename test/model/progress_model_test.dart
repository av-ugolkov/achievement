import 'package:achievement/data/entities/progress_entity.dart';
import 'package:achievement/data/model/progress_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgressModel', () {
    test('fromJson(toJson()) round-trips correctly', () {
      final model = ProgressModel(
        id: 1,
        progressDescription: {
          '2024-01-15': ProgressDescription(
            isDoAnything: true,
            description: 'Completed task',
          ),
          '2024-01-16': ProgressDescription(
            isDoAnything: false,
            description: 'Skipped',
          ),
        },
      );

      final result = ProgressModel.fromJson(model.toJson());

      expect(result.id, 1);
      expect(result.progressDescription.length, 2);
      expect(result.progressDescription['2024-01-15']!.isDoAnything, true);
      expect(result.progressDescription['2024-01-15']!.description, 'Completed task');
      expect(result.progressDescription['2024-01-16']!.isDoAnything, false);
      expect(result.progressDescription['2024-01-16']!.description, 'Skipped');
    });

    test('fromJson(toJson()) round-trips with empty progressDescription', () {
      final model = ProgressModel(id: 2, progressDescription: {});

      final result = ProgressModel.fromJson(model.toJson());

      expect(result.id, 2);
      expect(result.progressDescription, isEmpty);
    });

    test('empty factory produces sentinel id -1', () {
      expect(ProgressModel.empty.id, -1);
      expect(ProgressModel.empty.progressDescription, isEmpty);
    });
  });
}
