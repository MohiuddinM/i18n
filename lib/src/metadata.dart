import 'package:yaml/yaml.dart';

class Metadata {
  final Metadata? parent;
  final bool isDefault;
  final String defaultObjectName;
  final String? defaultFileName;
  final String objectName;
  final String localeName;
  final String languageCode;

  const Metadata({
    this.parent,
    required this.isDefault,
    required this.defaultObjectName,
    this.defaultFileName,
    required this.objectName,
    required this.localeName,
    required this.languageCode,
  });

  Metadata nest(String namePrefix) {
    return Metadata(
      parent: this,
      isDefault: isDefault,
      defaultObjectName: '$namePrefix$defaultObjectName',
      defaultFileName: defaultFileName,
      objectName: '$namePrefix$objectName',
      localeName: localeName,
      languageCode: languageCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Metadata &&
          runtimeType == other.runtimeType &&
          parent == other.parent &&
          isDefault == other.isDefault &&
          defaultObjectName == other.defaultObjectName &&
          defaultFileName == other.defaultFileName &&
          objectName == other.objectName &&
          localeName == other.localeName &&
          languageCode == other.languageCode;

  @override
  int get hashCode =>
      parent.hashCode ^
      isDefault.hashCode ^
      defaultObjectName.hashCode ^
      defaultFileName.hashCode ^
      objectName.hashCode ^
      localeName.hashCode ^
      languageCode.hashCode;

  @override
  String toString() {
    return 'Metadata(parent: $parent, isDefault: $isDefault, defaultObjectName: $defaultObjectName, defaultFileName: $defaultFileName, objectName: $objectName, localeName: $localeName, languageCode: $languageCode)';
  }
}

class Translation {
  final Metadata metadata;
  final YamlMap content;

  const Translation(this.metadata, this.content);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Translation &&
          runtimeType == other.runtimeType &&
          metadata == other.metadata &&
          content == other.content;

  @override
  int get hashCode => metadata.hashCode ^ content.hashCode;

  @override
  String toString() {
    return 'Translation(metadata: $metadata, content: $content)';
  }
}
