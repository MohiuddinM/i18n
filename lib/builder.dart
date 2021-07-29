// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore: import_of_legacy_library_into_null_safe
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:i18n/src/i18n_impl.dart';

Builder yamlBasedBuilder(BuilderOptions options) => YamlBasedBuilder();

class YamlBasedBuilder implements Builder {
  @override
  Future build(BuildStep buildStep) async {
    // Each [buildStep] has a single input.
    var inputId = buildStep.inputId;

    // Create a new target [AssetId] based on the old one.
    var contents = await buildStep.readAsString(inputId);

    var objectName = generateMessageObjectName(inputId.pathSegments.last);
    var dartContent = generateDartContentFromYaml(objectName, contents);

    try {
      dartContent = DartFormatter().format(dartContent);
    } on FormatterException {
      log.warning(
          'Could not format generated output, it might contain errors.');
    }

    var copy = inputId.changeExtension('.dart');

    // Write out the new asset.
    await buildStep.writeAsString(copy, dartContent);
  }

  @override
  final buildExtensions = const {
    '.i18n.yaml': ['.i18n.dart']
  };
}
