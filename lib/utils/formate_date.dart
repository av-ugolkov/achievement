import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class FormateDate {
  static final String _currentLocale = 'ru_RU';

  static final FormateDate _inst = FormateDate._();
  Map<String, DateFormat> _dateFormat;

  FormateDate._() {
    initializeDateFormatting();
    _dateFormat = {
      DateFormat.YEAR_MONTH_DAY:
          DateFormat(DateFormat.YEAR_MONTH_DAY, _currentLocale),
      DateFormat.YEAR_NUM_MONTH_DAY:
          DateFormat(DateFormat.YEAR_NUM_MONTH_DAY, _currentLocale),
      DateFormat.WEEKDAY: DateFormat(DateFormat.WEEKDAY, _currentLocale),
      DateFormat.HOUR24_MINUTE_SECOND:
          DateFormat(DateFormat.HOUR24_MINUTE_SECOND, _currentLocale),
      DateFormat.HOUR24_MINUTE:
          DateFormat(DateFormat.HOUR24_MINUTE, _currentLocale)
    };
  }

  static String yearMonthDay(DateTime dateTime) {
    return _inst._dateFormat[DateFormat.YEAR_MONTH_DAY].format(dateTime);
  }

  static String yearNumMonthDay(DateTime dateTime) {
    return _inst._dateFormat[DateFormat.YEAR_NUM_MONTH_DAY].format(dateTime);
  }

  static String weekDayName(DateTime dateTime) {
    return _inst._dateFormat[DateFormat.WEEKDAY].format(dateTime);
  }

  static String hour24MinuteSecond(DateTime dateTime) {
    return _inst._dateFormat[DateFormat.HOUR24_MINUTE_SECOND].format(dateTime);
  }

  static String hour24Minute(DateTime dateTime) {
    return _inst._dateFormat[DateFormat.HOUR24_MINUTE].format(dateTime);
  }
}
