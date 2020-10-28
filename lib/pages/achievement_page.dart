import '../widgets/achievement_card.dart';
import 'package:flutter/material.dart';

class AchievementPaage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Достигатор'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/create_achievement_page');
        },
      ),
      body: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return AchievementCard();
          }),
    );
  }
}
