import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/context_ext.dart';
import 'package:flutter_example/translation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Translation(
      child: MaterialApp(
        supportedLocales: Translation.supportedLocales,
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final translations = context.translations;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Row(),
          DropdownButton<String>(
            value: context.locale,
            items: Translation.supportedLocales
                .map((e) => DropdownMenuItem(
                      value: e.toString(),
                      child: Text(e.languageCode),
                    ))
                .toList(),
            onChanged: (locale) {
              locale ??= 'en_US';
              context.locale = locale.toString();
            },
          ),
          const SizedBox(height: 24),
          Text(translations.generic.done),
        ],
      ),
    );
  }
}
