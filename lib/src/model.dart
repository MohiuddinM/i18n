part of i18n;

class Metadata {
  final Metadata? parent;
  final bool isDefault;
  final String defaultObjectName;
  final String? defaultFileName;
  final String objectName;
  final String localeName;
  final String languageCode;

  Metadata({
    this.parent,
    required this.isDefault,
    required this.defaultObjectName,
    this.defaultFileName,
    required this.objectName,
    required this.localeName,
    required this.languageCode,
  });

  Metadata nest(String namePrefix) {
    final result = Metadata(
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

class Translation {
  Metadata metadata;
  YamlMap content;

  Translation(this.metadata, this.content);
}
