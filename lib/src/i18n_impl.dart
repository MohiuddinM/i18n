library i18n;

import 'package:yaml/yaml.dart';

part 'model.dart';

Pattern twoCharsLower = RegExp('^[a-z]{2}\$');
Pattern twoCharsUpper = RegExp('^[A-Z]{2}\$');

String generateDartContentFromYaml(ClassMeta meta, String yamlContent) {
  final messages = loadYaml(yamlContent);

  final todoList = <TodoItem>[];

  prepareTodoList(todoList, messages, meta);

  final output = StringBuffer();

  output.writeln('// GENERATED FILE, do not edit!');
  output.writeln('import \'package:i18n/i18n.dart\' as i18n;');
  if (meta.defaultFileName != null) {
    output.writeln("import '${meta.defaultFileName}';");
  }
  output.writeln('');
  output.writeln('String get _languageCode => \'${meta.languageCode}\';');
  output.writeln('String get _localeName => \'${meta.localeName}\';');
  output.writeln('');
  output.writeln('String _plural(int count, {String zero, String one, String two, String few, String many, String other}) =>');
  output.writeln('\ti18n.plural(count, _languageCode, zero:zero, one:one, two:two, few:few, many:many, other:other);');
  output.writeln('String _ordinal(int count, {String zero, String one, String two, String few, String many, String other}) =>');
  output.writeln('\ti18n.ordinal(count, _languageCode, zero:zero, one:one, two:two, few:few, many:many, other:other);');
  output.writeln('String _cardinal(int count, {String zero, String one, String two, String few, String many, String other}) =>');
  output.writeln('\ti18n.cardinal(count, _languageCode, zero:zero, one:one, two:two, few:few, many:many, other:other);');
  output.writeln('');

  for (var todo in todoList) {
    renderTodoItem(todo, output);
    output.writeln('');
  }

  return output.toString();
}

ClassMeta generateMessageObjectName(String fileName) {
  final name = fileName.replaceAll('.i18n.yaml', '');

  final nameParts = name.split('_');
  if (nameParts.isEmpty) {
    throw Exception(_renderFileNameError(name));
  }

  final result = ClassMeta();

  result.defaultObjectName = _firstCharUpper(nameParts[0]);

  if (nameParts.length == 1) {
    result.objectName = result.defaultObjectName;
    result.isDefault = true;
    result.languageCode = 'en';
    result.localeName = 'en';
    return result;
  } else {
    result.defaultFileName = '${nameParts[0]}.i18n.dart';
    result.isDefault = false;

    if (nameParts.length > 3) {
      throw Exception(_renderFileNameError(name));
    }
    if (nameParts.length >= 2) {
      final languageCode = nameParts[1];
      if (twoCharsLower.allMatches(languageCode).length != 1) {
        throw Exception('Wrong language code "$languageCode" in file name "$fileName". Language code must match $twoCharsLower');
      }
      result.languageCode = languageCode;
      result.localeName = languageCode;
    }
    if (nameParts.length == 3) {
      final countryCode = nameParts[2];
      if (twoCharsUpper
          .allMatches(countryCode)
          .length != 1) {
        throw Exception('Wrong country code "$countryCode" in file name "$fileName". Country code must match $twoCharsUpper');
      }
      result.localeName = '${result.languageCode}_${countryCode}';
    }
    result.objectName = "${result.defaultObjectName}_${result.localeName}";
    return result;
  }
}

void renderTodoItem(TodoItem todo, StringBuffer output) {
  final meta = todo.meta;
  final content = todo.content;
  if (meta.isDefault) {
    output.writeln('class ${meta.objectName} {');
  } else {
    output.writeln('class ${meta.objectName} extends ${meta.defaultObjectName} {');
  }

  if (meta.parent == null) {
    output.writeln('\tconst ${meta.objectName}();');
  } else {
    output.writeln('\tfinal ${meta.parent.objectName} _parent;');
    if (meta.isDefault) {
      output.writeln('\tconst ${meta.objectName}(this._parent);');
    } else {
      output.writeln('\tconst ${meta.objectName}(this._parent):super(_parent);');
    }
  }
  content.forEach((k, v) {
    if (v is YamlMap) {
      final prefix = _firstCharUpper(k);
      final child = meta.nest(prefix);
      output.writeln('\t${child.objectName} get ${k} => ${child.objectName}(this);');
    } else {
      if (k.contains('(')) {
        // function
        output.writeln('\tString ${k} => "${v}";');
      } else {
        output.writeln('\tString get ${k} => "${v}";');
      }
    }
  });
  output.writeln('}');
}

void prepareTodoList(List<TodoItem> todoList, YamlMap messages, ClassMeta name) {
  final todo = TodoItem(name, messages);
  todoList.add(todo);

  messages.forEach((k, v) {
    if (v is YamlMap) {
      final prefix = _firstCharUpper(k);
      prepareTodoList(todoList, v, name.nest(prefix));
    }
  });
}

String _firstCharUpper(String s) {
  return s.replaceRange(0, 1, s[0].toUpperCase());
}

String _renderFileNameError(String name) {
  return 'Wrong file name: \'$name\'';
}
