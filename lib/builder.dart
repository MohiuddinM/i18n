// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore: import_of_legacy_library_into_null_safe
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:i18n/src/i18n_impl.dart';
import 'package:glob/glob.dart';
import 'package:yaml/yaml.dart';

Builder yamlBasedBuilder(BuilderOptions options) => YamlBasedBuilder();

void collectAllKeys(YamlMap map, List<String> keys) {
  map.cast<String, dynamic>().forEach((k, v) {
    keys.add(k);

    if (v is YamlMap) {
      collectAllKeys(v, keys);
    }
  });
}

extension YamlMapX on YamlMap {
  List<String> get allKeys {
    final keys = <String>[];
    collectAllKeys(this, keys);
    return keys;
  }
}

class YamlBasedBuilder implements Builder {
  @override
  Future build(BuildStep buildStep) async {
    // Each [buildStep] has a single input.
    final currentAsset = buildStep.inputId;
    final contents = await buildStep.readAsString(currentAsset);
    final currentMap = loadYaml(contents) as YamlMap;
    final currentKeys = currentMap.allKeys;

    final all = await buildStep.findAssets(Glob('**.i18n.yaml')).toList()
      ..remove(currentAsset);

    for (final a in all) {
      var contents = await buildStep.readAsString(a);
      final map = loadYaml(contents) as YamlMap;
      final keys = map.allKeys;

      if (currentKeys.length != keys.length) {
        throw 'all language YAMLs must have equal length';
      }

      for (var i = 0; i < currentKeys.length; i++) {
        if (currentKeys[i] != keys[i]) {
          throw 'different keys were found for the same location ${keys[i]} [$a]';
        }
      }
    }


    // Create a new target [AssetId] based on the old one.

    var objectName = generateMessageObjectName(currentAsset.pathSegments.last);
    var dartContent = generateDartContentFromYaml(objectName, contents);

    try {
      dartContent = DartFormatter().format(dartContent);
    } on FormatterException {
      log.warning(
          'Could not format generated output, it might contain errors.');
    }

    var copy = currentAsset.changeExtension('.dart');

    // Write out the new asset.
    await buildStep.writeAsString(copy, dartContent);
  }

  @override
  final buildExtensions = const {
    '.i18n.yaml': ['.i18n.dart']
  };
}
