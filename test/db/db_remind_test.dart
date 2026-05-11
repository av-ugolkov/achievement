import 'package:achievement/core/enums.dart';
import 'package:achievement/data/entities/remind_entity.dart';
import 'package:achievement/data/model/remind_model.dart';
import 'package:achievement/db/db_file.dart';
import 'package:achievement/db/db_remind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

RemindModel _remind({TypeRepetition type = TypeRepetition.none, int minute = 0}) {
  return RemindModel(
    id: -1,
    remindDateTime: RemindDateTime(
      year: 2024,
      month: 6,
      day: 1,
      hour: 8,
      minute: minute,
    ),
    typeRepetition: type,
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database testDb;

  setUp(() async {
    testDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await DbRemind.db.createTable(testDb);
    DbFile.initForTest(testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  group('DbRemind.getRemind', () {
    test('returns correct record by ID', () async {
      final inserted = await DbRemind.db.insert(_remind(type: TypeRepetition.day));

      final result = await DbRemind.db.getRemind(inserted.id);

      expect(result.id, inserted.id);
      expect(result.typeRepetition, TypeRepetition.day);
      expect(result.remindDateTime.year, 2024);
      expect(result.remindDateTime.hour, 8);
    });

    test('returns correct record when multiple records exist', () async {
      await DbRemind.db.insert(_remind());
      await DbRemind.db.insert(_remind());
      final target = await DbRemind.db.insert(_remind(type: TypeRepetition.week));

      final result = await DbRemind.db.getRemind(target.id);

      expect(result.id, target.id);
      expect(result.typeRepetition, TypeRepetition.week);
    });

    test('returns empty model for non-existent ID', () async {
      final result = await DbRemind.db.getRemind(9999);
      expect(result.id, -1);
    });

    test('returns empty model for sentinel -1', () async {
      final result = await DbRemind.db.getRemind(-1);
      expect(result.id, -1);
    });
  });

  group('DbRemind.getReminds', () {
    test('returns all requested records in order', () async {
      final r1 = await DbRemind.db.insert(_remind(type: TypeRepetition.none));
      final r2 = await DbRemind.db.insert(_remind(type: TypeRepetition.week));

      final results = await DbRemind.db.getReminds([r1.id, r2.id]);

      expect(results.length, 2);
      expect(results[0].id, r1.id);
      expect(results[1].id, r2.id);
      expect(results[1].typeRepetition, TypeRepetition.week);
    });

    test('skips non-existent IDs', () async {
      final r1 = await DbRemind.db.insert(_remind());

      final results = await DbRemind.db.getReminds([r1.id, 9999]);

      expect(results.length, 1);
      expect(results[0].id, r1.id);
    });

    test('returns empty list for empty input', () async {
      final results = await DbRemind.db.getReminds([]);
      expect(results, isEmpty);
    });
  });
}
