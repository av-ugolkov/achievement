import 'package:achievement/data/entities/progress_entity.dart';
import 'package:achievement/data/model/progress_model.dart';
import 'package:achievement/db/db_file.dart';
import 'package:achievement/db/db_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database testDb;

  setUp(() async {
    testDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await DbProgress.db.createTable(testDb);
    DbFile.initForTest(testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  group('DbProgress.getProgress', () {
    test('returns correct record by ID', () async {
      final inserted = await DbProgress.db.insert(
        ProgressModel(
          id: -1,
          progressDescription: {
            '2024-01-01': ProgressDescription(
              isDoAnything: true,
              description: 'First entry',
            ),
          },
        ),
      );

      final result = await DbProgress.db.getProgress(inserted.id);

      expect(result.id, inserted.id);
      expect(result.progressDescription.length, 1);
      expect(result.progressDescription['2024-01-01']!.isDoAnything, true);
      expect(result.progressDescription['2024-01-01']!.description, 'First entry');
    });

    test('returns correct record when multiple records exist', () async {
      await DbProgress.db.insert(ProgressModel(id: -1, progressDescription: {}));
      await DbProgress.db.insert(ProgressModel(id: -1, progressDescription: {}));
      final target = await DbProgress.db.insert(
        ProgressModel(
          id: -1,
          progressDescription: {
            '2024-05-01': ProgressDescription(
              isDoAnything: false,
              description: 'Target entry',
            ),
          },
        ),
      );

      final result = await DbProgress.db.getProgress(target.id);

      expect(result.id, target.id);
      expect(result.progressDescription['2024-05-01']!.description, 'Target entry');
    });

    test('returns empty model for non-existent ID', () async {
      final result = await DbProgress.db.getProgress(9999);
      expect(result.id, -1);
    });

    test('returns empty model for sentinel -1', () async {
      final result = await DbProgress.db.getProgress(-1);
      expect(result.id, -1);
    });
  });
}
