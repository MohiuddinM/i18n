library i18n;

import 'dart:convert';

import 'package:yaml/yaml.dart';

import 'metadata.dart';
import 'string_ext.dart';

Pattern twoCharsLower = RegExp('^[a-z]{2}\$');
Pattern twoCharsUpper = RegExp('^[A-Z]{2}\$');

String generateDartContentFromYaml(Metadata meta, String yamlContent) {
  final messages = loadYaml(yamlContent);

  final translations = <Translation>[];

  prepareTranslationList(translations, messages, meta);

  final output = StringBuffer();

  output.writeln('// GENERATED FILE, do not edit!');
  output.writeln(
    '// ignore_for_file: annotate_overrides, non_constant_identifier_names, prefer_single_quotes, unused_element, unused_field',
  );
  output.writeln('import \'package:i18n/i18n.dart\' as i18n;');
  if (meta.defaultFileName != null) {
    output.writeln("import '${meta.defaultFileName}';");
  }
  output.writeln(
    '\tString get _languageCode => \'${meta.languageCode}\';',
  );
  output.writeln(
    '\tString _plural(int count, {String? zero, String? one, String? two, String? few, String? many, String? other,}) =>',
  );
  output.writeln(
    '\ti18n.plural(count, _languageCode, zero: zero, one: one, two: two, few: few, many: many, other: other,);',
  );
  output.writeln(
    'String _ordinal(int count, {String? zero, String? one, String? two, String? few, String? many, String? other,}) =>',
  );
  output.writeln(
    '\ti18n.ordinal(count, _languageCode, zero: zero, one: one, two: two, few: few, many: many, other: other,);',
  );
  output.writeln(
    'String _cardinal(int count, {String? zero, String? one, String? two, String? few, String? many, String? other,}) =>',
  );
  output.writeln(
    '\ti18n.cardinal(count, _languageCode, zero: zero, one: one, two: two, few: few, many: many, other: other,);',
  );
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
    throw ArgumentError(_renderFileNameError(name));
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
      throw ArgumentError(_renderFileNameError(name));
    }
    if (nameParts.length >= 2) {
      languageCode = nameParts[1];
      if (twoCharsLower.allMatches(languageCode).length != 1) {
        throw Exception(
          'Wrong language code "$languageCode" in file name "$fileName". Language code must match $twoCharsLower',
        );
      }
      languageCode = languageCode;
      localeName = languageCode;
    }
    if (nameParts.length == 3) {
      final countryCode = nameParts[2];
      if (twoCharsUpper.allMatches(countryCode).length != 1) {
        throw Exception(
          'Wrong country code "$countryCode" in file name "$fileName". Country code must match $twoCharsUpper',
        );
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
  final defaultClassName = meta.defaultObjectName.convertName();
  final className = meta.objectName.convertName();
  final parentClassName = meta.parent?.objectName.convertName();

  if (meta.isDefault) {
    output.writeln('class $className {');
  } else {
    output.writeln('class $className extends $defaultClassName {');
  }

  if (parentClassName == null) {
    output.writeln('\tconst $className();');
    output.writeln('\tString get locale => "${meta.localeName}";');
    output.writeln('\tString get languageCode => "${meta.languageCode}";');
  } else {
    output.writeln('\tfinal $parentClassName _parent;');
    if (meta.isDefault) {
      output.writeln('\tconst $className(this._parent);');
    } else {
      output.writeln('\tconst $className(this._parent):super(_parent);');
    }
  }

  content.cast<String, dynamic>().forEach((k, v) {
    final keyName = k.filterSpaces().filterHyphen();
    if (v is YamlMap) {
      final prefix = keyName.firstUpper();
      final className = meta.nest(prefix).objectName.convertName();
      output.writeln('\t$className get $keyName => $className(this);');
    } else {
      final comment = _wrapWithComments(v);
      output.writeln(comment);
      if (k.contains('(')) {
        // function
        output.writeln('\tString $keyName => """$v""";');
      } else {
        output.writeln('\tString get $keyName => """$v""";');
      }
    }
  });
  output.writeln('}');
}

String _wrapWithComments(dynamic obj) {
  final text = obj?.toString();
  if (text == null || text.isEmpty) {
    return '';
  }
  final lines = LineSplitter().convert(text);
  final output = StringBuffer();
  final isMultiline = lines.length > 1;
  output.writeln('/// ```dart');
  if (isMultiline) {
    output.writeln('/// """');
    for (final line in lines) {
      output.writeln('/// $line');
    }
    output.writeln('/// """');
  } else {
    output.writeln('/// "$text"');
  }
  output.writeln('/// ```');
  return output.toString().trimRight();
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
  return 'File name can not contain more than 2 "_" characters: \'$name\'';
}

