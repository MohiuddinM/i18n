import 'package:flutter/cupertino.dart';
import 'package:flutter_example/translation.dart';

import 'i18n/translations.i18n.dart';

extension BuildContextX on BuildContext {
  String get locale => Translation.of(this).locale;

  set locale(String locale) => Translation.of(this).locale = locale;

  Translations get translations => Translation.of(this).translations;
}
