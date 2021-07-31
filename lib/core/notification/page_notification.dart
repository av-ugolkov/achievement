import 'dart:developer';

import 'package:achievement/core/notification/local_notification.dart';
import 'package:achievement/core/notification/payload.dart';
import 'package:achievement/core/page_routes.dart';
import 'package:achievement/data/model/achievement_model.dart';
import 'package:achievement/db/db_achievement.dart';
import 'package:flutter/material.dart';

mixin PageNotification {
  late final BuildContext _context;

  void initOpenPayload(BuildContext context) {
    _context = context;
    LocalNotification.subscribeOpenPayloadEvent(_openPayload);
  }

  void destroyOpenPayload() {
    LocalNotification.unsubscribeOpenPayloadEvent(_openPayload);
  }

  void _openPayload(Payload? payload) {
    if (payload != null) {
      _onOpenPayloadMixin(_context, payload);
    }
  }

  Future<void> _onOpenPayloadMixin(
      BuildContext context, Payload payload) async {
    switch (payload.command) {
      case 'open':
        log('start open');
        var achievements = await DbAchievement.db.getList();
        var model = achievements[payload.achievementId];
        LocalNotification.clearPayload();
        var result = await Navigator.pushNamed(
            context, RouteViewAchievementPage,
            arguments: model);
        var newModel = result as AchievementModel;
        model.setModel(newModel);
        //setState(() {});
        break;
      default:
        log('Error open achievement');
    }
  }
}
