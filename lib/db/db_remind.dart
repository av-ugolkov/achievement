import 'db_file.dart';

class DbRemind {
  DbRemind._();

  final String _nameTable = 'RemindDB';

  final String _id = 'id';
  final String _period = 'period';
  final String _days = 'days';
  final String _months = 'months';
  final String _hour = 'hour';
  final String _minute = 'minute';

  static final DbRemind db = DbRemind._();

  Future<void> createTable() async {
    await DbFile.db.execute(
      'CREATE TABLE $_nameTable($_id INTEGER PRIMARY KEY AUTOINCREMENT, $_period TEXT, $_days TEXT, $_months TEXT, $_hour INTEGER, $_minute INTEGER)',
    );
  }
}
