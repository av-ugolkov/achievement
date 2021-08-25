import 'package:achievement/core/data_application.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('О приложении'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DataApplication.version),
              Text(DataApplication.author),
              InkWell(
                  onTap: () {
                    launch(DataApplication.homePage);
                  },
                  child: Text(
                    DataApplication.homePage,
                    style: TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
