library i18n;

import 'package:yaml/yaml.dart';

import 'string_ext.dart';

part 'model.dart';

Pattern twoCharsLower = RegExp('^[a-z]{2}\$');
Pattern twoCharsUpper = RegExp('^[A-Z]{2}\$');

String generateDartContentFromYaml(Metadata meta, String yamlContent) {
  final messages = loadYaml(yamlContent);

  final translations = <Translation>[];

  prepareTranslationList(translations, messages, meta);

  final output = StringBuffer();

  output.writeln('// GENERATED FILE, do not edit!');
  output.writeln('// ignore_for_file: unused_element, unused_field');
  output.writeln('import \'package:i18n/i18n.dart\' as i18n;');
  if (meta.defaultFileName != null) {
    output.writeln("import '${meta.defaultFileName}';");
  }
  output.writeln('\tString get _languageCode => \'${meta.languageCode}\';');
  output.writeln(
      '\tString _plural(int count, {String? zero, String? one, String? two, String? few, String? many, String? other}) =>');
  output.writeln(
      '\ti18n.plural(count, _languageCode, zero:zero, one:one, two:two, few:few, many:many, other:other);');
  output.writeln(
      'String _ordinal(int count, {String? zero, String? one, String? two, String? few, String? many, String? other}) =>');
  output.writeln(
      '\ti18n.ordinal(count, _languageCode, zero:zero, one:one, two:two, few:few, many: many, other: other,);');
  output.writeln(
      'String _cardinal(int count, {String? zero, String? one, String? two, String? few, String? many, String? other,}) =>');
  output.writeln(
      '\ti18n.cardinal(count, _languageCode, zero:zero, one:one, two:two, few:few, many: many, other: other,);');
  output.writeln('');

  for (final translation in translations) {
    renderTranslation(translation, output);
    output.writeln('');
  }

  output.writeln();
  output.writeln(
      'Map<String, String> get ${meta.objectName.convertName().firstLower()}Map => {');
  renderMapEntries(messages, output, '');
  output.writeln('};');

  return output.toString();
}

Metadata generateMessageObjectName(String fileName) {
  final name = fileName.replaceAll('.i18n.yaml', '');

  final nameParts = name.split('_');
  if (nameParts.isEmpty) {
    throw Exception(_renderFileNameError(name));
  }

  var defaultObjectName = nameParts[0].firstUpper();
  var objectName = defaultObjectName;
  String? defaultFileName;
  var isDefault = true;
  var languageCode = 'en';
  var localeName = 'en';

  if (nameParts.length == 1) {
    return Metadata(
      languageCode: languageCode,
      objectName: objectName,
      defaultObjectName: defaultObjectName,
      isDefault: isDefault,
      localeName: localeName,
      defaultFileName: defaultFileName,
    );
  } else {
    defaultFileName = '${nameParts[0]}.i18n.dart';
    isDefault = false;

    if (nameParts.length > 3) {
      throw Exception(_renderFileNameError(name));
    }
    if (nameParts.length >= 2) {
      languageCode = nameParts[1];
      if (twoCharsLower.allMatches(languageCode).length != 1) {
        throw Exception(
            'Wrong language code "$languageCode" in file name "$fileName". Language code must match $twoCharsLower');
      }
      languageCode = languageCode;
      localeName = languageCode;
    }
    if (nameParts.length == 3) {
      final countryCode = nameParts[2];
      if (twoCharsUpper.allMatches(countryCode).length != 1) {
        throw Exception(
            'Wrong country code "$countryCode" in file name "$fileName". Country code must match $twoCharsUpper');
      }
      localeName = '${languageCode}_$countryCode';
    }
    objectName = '${defaultObjectName}_$localeName';
    return Metadata(
      languageCode: languageCode,
      objectName: objectName,
      defaultObjectName: defaultObjectName,
      isDefault: isDefault,
      localeName: localeName,
      defaultFileName: defaultFileName,
    );
  }
}

void renderTranslation(Translation translation, StringBuffer output) {
  final meta = translation.metadata;
  final content = translation.content;
  if (meta.isDefault) {
    output.writeln('class ${meta.objectName} {');
  } else {
    output.writeln(
        'class ${meta.objectName.convertName()} extends ${meta.defaultObjectName} {');
  }

  var parent = meta.parent;
  if (parent == null) {
    output.writeln('\tconst ${meta.objectName.convertName()}();');
    output.writeln('\tString get locale => "${meta.localeName}";');
    output.writeln('\tString get languageCode => "${meta.languageCode}";');
  } else {
    output.writeln('\tfinal ${parent.objectName.convertName()} _parent;');
    if (meta.isDefault) {
      output.writeln('\tconst ${meta.objectName}(this._parent);');
    } else {
      output.writeln(
          '\tconst ${meta.objectName.convertName()}(this._parent):super(_parent);');
    }
  }

  content.cast<String, dynamic>().forEach((k, v) {
    if (v is YamlMap) {
      final prefix = k.firstUpper();
      final child = meta.nest(prefix);
      output.writeln(
          '\t${child.objectName.convertName()} get $k => ${child.objectName.convertName()}(this);');
    } else {
      if (k.contains('(')) {
        // function
        output.writeln('\tString $k => """$v""";');
      } else {
        output.writeln('\tString get $k => """$v""";');
      }
    }
  });
  output.writeln('}');
}

void prepareTranslationList(
  List<Translation> translations,
  YamlMap messages,
  Metadata name,
) {
  final translation = Translation(name, messages);
  translations.add(translation);

  messages.cast<String, dynamic>().forEach((k, v) {
    if (v is YamlMap) {
      final prefix = k.firstUpper();
      prepareTranslationList(translations, v, name.nest(prefix));
    }
  });
}

void renderMapEntries(YamlMap messages, StringBuffer output, String prefix) {
  messages.cast<String, dynamic>().forEach((k, v) {
    if (v is YamlMap) {
      if (prefix == '') {
        renderMapEntries(v, output, '$k.');
      } else {
        renderMapEntries(v, output, '$prefix$k.');
      }
    } else if (v is String) {
      if (!v.containsReference) {
        output.writeln('\t"""$prefix$k""": """$v""",');
      }
    }
  });
}

String _renderFileNameError(String name) {
  return 'Wrong file name: \'$name\'';
}
