part of i18n;

class ClassMeta {
  final ClassMeta? parent;
  final bool isDefault;
  final String defaultObjectName;
  final String? defaultFileName;
  final String objectName;
  final String localeName;
  final String languageCode;

  ClassMeta({
    this.parent,
    required this.isDefault,
    required this.defaultObjectName,
    this.defaultFileName,
    required this.objectName,
    required this.localeName,
    required this.languageCode,
  });

  ClassMeta nest(String namePrefix) {
    final result = ClassMeta(
      parent: this,
      isDefault: isDefault,
      defaultObjectName: '$namePrefix$defaultObjectName',
      defaultFileName: defaultFileName,
      objectName: '$namePrefix$objectName',
      localeName: localeName,
      languageCode: languageCode,
    );
    return result;
  }
}

class TodoItem {
  ClassMeta meta;
  YamlMap content;

  TodoItem(this.meta, this.content);
}
