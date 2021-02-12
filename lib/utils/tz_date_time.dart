import 'package:timezone/standalone.dart' as tz;

class TZDateTime {
  TZDateTime() {
    initTZ();
  }

  Future<void> initTZ() async {
    await tz.initializeTimeZone();
  }
}
