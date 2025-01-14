import 'dart:io';
import 'dart:math';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:i18n/src/i18n_impl.dart';
import 'package:pub_semver/pub_semver.dart';
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
    final currentFile = buildStep.inputId;
    final contents = await buildStep.readAsString(currentFile);
    final currentMap = loadYaml(contents) as YamlMap;
    final currentKeys = currentMap.allKeys;

    final pattern = Glob('**.i18n.yaml');
    final allFiles = await buildStep.findAssets(pattern).toList();
    final currentFileName = currentFile.pathSegments.last.replaceAll(
      '.i18n.yaml',
      '',
    );
    final defaultFile = allFiles.firstWhere(
      (e) {
        final name = e.uri.pathSegments.last.replaceAll('.i18n.yaml', '');
        return !name.contains('_') && currentFileName.startsWith(name);
      },
    );

    if (currentFile != defaultFile) {
      final defaultFileContents = await buildStep.readAsString(defaultFile);
      final defaultMap = loadYaml(defaultFileContents) as YamlMap;
      final defaultKeys = defaultMap.allKeys;
      final maxLength = max(currentKeys.length, defaultKeys.length);

      for (var i = 0; i < maxLength; i++) {
        final currentKey = currentKeys.elementAtOrNull(i);
        final defaultKey = defaultKeys.elementAtOrNull(i);

        if (currentKey == null) {
          log.severe('key "$defaultKey" not found in file $defaultFile');
        }

        if (defaultKey == null) {
          log.severe('key "$currentKey" not found in file $currentFile');
        }

        if (currentKey != defaultKey) {
          log.severe(
            'same location contains 2 different keys:'
            '\n\t"$currentKey" in $currentFile'
            '\n\t"$defaultKey" in $defaultFile',
          );
        }
      }
    }

    final objectName = generateMessageObjectName(currentFile.pathSegments.last);
    var dartContent = generateDartContentFromYaml(objectName, contents);

    try {
      final versionText = Platform.version;
      final version = versionText.substring(
        0,
        versionText.indexOf(' '),
      );
      final formatter = DartFormatter(languageVersion: Version.parse(version));
      dartContent = formatter.format(dartContent);
    } on FormatterException {
      log.warning(
        'Could not format generated output, it might contain errors.',
      );
    }

    final copy = currentFile.changeExtension('.dart');

    // Write out the new asset.
    await buildStep.writeAsString(copy, dartContent);
  }

  @override
  final buildExtensions = const {
    '.i18n.yaml': ['.i18n.dart']
  };
}
