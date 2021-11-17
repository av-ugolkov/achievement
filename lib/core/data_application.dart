import 'package:flutter/services.dart';

class DataApplication {
  static const int _addIndex = 2;
  static late String description;
  static late String version;
  static late String homePage;

  DataApplication() {
    rootBundle.loadString('pubspec.yaml').then((value) {
      var yaml = value.split('\r\n');
      description = _getTextFromYaml(yaml, 'description');
      version = _getTextFromYaml(yaml, 'version');
      homePage = _getTextFromYaml(yaml, 'homepage');
    });
  }

  String _getTextFromYaml(List<String> yaml, String key) {
    var value = yaml.firstWhere((element) => element.startsWith(key));
    if (value.isEmpty) {
      throw Exception('Not found key $key');
    }
    return value.substring(value.indexOf(':') + _addIndex);
  }
}
