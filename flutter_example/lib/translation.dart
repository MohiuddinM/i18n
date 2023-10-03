import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_example/i18n/translations.i18n.dart';
import 'package:flutter_example/i18n/translations_de.i18n.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Translation extends StatefulWidget {
  const Translation({
    super.key,
    required this.child,
  });

  final Widget child;

  static TranslationState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TranslationContainer>()!
        .data;
  }

  static const supportedLocales = [Locale('en', 'US'), Locale('de', 'DE')];

  @override
  State<Translation> createState() => TranslationState();
}

class TranslationState extends State<Translation> {
  late String _locale;

  String get locale => _locale;

  Translations translations = const Translations();

  void _switchTranslation(String locale) {
    Intl.defaultLocale = locale;

    if (locale.startsWith('de')) {
      translations = const TranslationsDe();
    } else {
      translations = const Translations();
    }
  }

  Future<bool> _initialize() async {
    final preferences = await SharedPreferences.getInstance();

    _locale = preferences.getString('locale') ?? await findSystemLocale();
    _switchTranslation(_locale);

    return true;
  }

  set locale(String locale) {
    if (locale == _locale) {
      return;
    }

    _switchTranslation(locale);

    SharedPreferences.getInstance().then((preferences) {
      preferences.setString('locale', locale);
    });

    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _TranslationContainer(
      data: this,
      child: FutureBuilder<bool>(
        future: _initialize(),
        builder: (context, s) {
          if (s.hasData && (s.data ?? false)) {
            return widget.child;
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _TranslationContainer extends InheritedWidget {
  final TranslationState data;

  const _TranslationContainer({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  // Note: we could get fancy here and compare whether the old AppState is
  // different than the current AppState. However, since we know this is the
  // root Widget, when we make changes we also know we want to rebuild Widgets
  // that depend on the StateContainer.
  @override
  bool updateShouldNotify(_TranslationContainer old) => true;
}
