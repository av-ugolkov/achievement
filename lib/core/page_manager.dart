import 'package:achievement/core/notification/page_notification.dart';
import 'package:flutter/widgets.dart';

class PageManager {
  PageManager._();

  static final PageManager _inst = PageManager._();

  final PageNotification _pageNotification = PageNotification();

  static void init(BuildContext context) {
    _inst._pageNotification.subscribeOpenPayload(context);
  }

  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    _inst._pageNotification.subscribeOpenPayload(context);
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    _inst._pageNotification.unsubscribeOpenPayload();
    Navigator.of(context).pop<T>(result);
  }
}
