import 'package:achievement/bridge/localization.dart';
import 'package:achievement/core/data_application.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  static const String _iconAchievement =
      'android/app/src/main/res/drawable/icon_achievement.png';

  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('О приложении'),
      ),
      body: Container(
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 150),
                  Image.asset(
                    _iconAchievement,
                    scale: 4,
                  ),
                  Text(
                    getLocaleOfContext(context).app_name,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline5!.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Версия: ${DataApplication.version}'),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(DataApplication.author),
                  InkWell(
                    onTap: () {
                      launch(DataApplication.homePage);
                    },
                    child: Text(
                      DataApplication.homePage,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(color: Colors.blueAccent),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      launch(DataApplication.homePage);
                    },
                    child: Text('Политика конфиденциальности',
                        style: Theme.of(context).textTheme.bodyText2),
                  ),
                  SizedBox(height: 8)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
