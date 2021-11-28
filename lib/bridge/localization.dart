import 'package:achievement/generated/l10n.dart';
import 'package:flutter/widgets.dart';

S getLocaleOfContext(BuildContext context) {
  return S.of(context);
}

S getLocaleCurrent() {
  return S.current;
}
