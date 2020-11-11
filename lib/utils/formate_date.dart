import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class FormateDate {
  FormateDate._() {
    initializeDateFormatting();
    _dateFormat = {
      DateFormat.YEAR_MONTH_DAY:
          DateFormat(DateFormat.YEAR_MONTH_DAY, _currentLocale),
      DateFormat.YEAR_NUM_MONTH_DAY:
          DateFormat(DateFormat.YEAR_NUM_MONTH_DAY, _currentLocale)
    };
  }

  static final String _currentLocale = 'ru_RU';

  static final FormateDate _inst = FormateDate._();

  Map<String, DateFormat> _dateFormat;

  static String yearMonthDay(DateTime dateTime) {
    if (_inst._dateFormat.containsKey(DateFormat.YEAR_MONTH_DAY))
      return _inst._dateFormat[DateFormat.YEAR_MONTH_DAY].format(dateTime);
    return dateTime.toString();
  }

  static String yearNumMonthDay(DateTime dateTime) {
    if (_inst._dateFormat.containsKey(DateFormat.YEAR_NUM_MONTH_DAY))
      return _inst._dateFormat[DateFormat.YEAR_NUM_MONTH_DAY].format(dateTime);
    return dateTime.toString();
  }
}
