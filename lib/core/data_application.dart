import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class DataApplication {
  static late String description;
  static late String version;
  static late String author;
  static late String homePage;

  DataApplication() {
    var f = rootBundle.loadString('pubspec.yaml');
    f.then((value) {
      var yaml = loadYaml(value) as Map<dynamic, dynamic>;
      description = yaml['description'].toString();
      version = yaml['version'].toString();
      author = yaml['author'].toString();
      homePage = yaml['homepage'].toString();
    });
  }
}
