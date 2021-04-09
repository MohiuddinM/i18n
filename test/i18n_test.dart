import 'package:i18n/i18n.dart';
import 'package:i18n/src/i18n_impl.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Messages meta data', () {
    testMeta('messages',
        isDefault: true,
        defaultObjectName: 'Messages',
        objectName: 'Messages',
        languageCode: 'en',
        localeName: 'en');
    testMeta('messages_de',
        isDefault: false,
        defaultObjectName: 'Messages',
        objectName: 'Messages_de',
        languageCode: 'de',
        localeName: 'de');

    testMeta('domainMessages',
        isDefault: true,
        defaultObjectName: 'DomainMessages',
        objectName: 'DomainMessages',
        languageCode: 'en',
        localeName: 'en');
    testMeta('domainMessages_de',
        isDefault: false,
        defaultObjectName: 'DomainMessages',
        objectName: 'DomainMessages_de',
        languageCode: 'de',
        localeName: 'de');
    testMeta('domainMessages_de_DE',
        isDefault: false,
        defaultObjectName: 'DomainMessages',
        objectName: 'DomainMessages_de_DE',
        languageCode: 'de',
        localeName: 'de_DE');
  });

  group('Plurals', () {
    test('en', () {
      expect(plural(1, 'en', one: 'ONE!', few: 'FEW!', other: 'OTHER!'),
          equals('ONE!'));
      expect(plural(2, 'en', one: 'ONE!', few: 'FEW!', other: 'OTHER!'),
          equals('OTHER!'));
      expect(plural(3, 'en', one: 'ONE!', few: 'FEW!', other: 'OTHER!'),
          equals('OTHER!'));
      expect(plural(10, 'en', one: 'ONE!', few: 'FEW!', other: 'OTHER!'),
          equals('OTHER!'));
    });

    test('cz', () {
      expect(plural(1, 'cs', one: 'ONE!', few: 'FEW!', other: 'OTHER!'),
          equals('ONE!'));
      expect(plural(2, 'cs', one: 'ONE!', few: 'FEW!', other: 'OTHER!'),
          equals('FEW!'));
      expect(plural(3, 'cs', one: 'ONE!', few: 'FEW!', other: 'OTHER!'),
          equals('FEW!'));
      expect(plural(10, 'cs', one: 'ONE!', few: 'FEW!', other: 'OTHER!'),
          equals('OTHER!'));
    });
  });

  group('Message building', () {
    test('Todo list', () {
      final root = Metadata(
          objectName: 'Test',
          defaultObjectName: 'Test',
          localeName: 'en',
          isDefault: false,
          languageCode: 'en',
          defaultFileName: '');

      final todoList = <Translation>[];
      var yaml = 'foo:\n'
          '  subfoo: subbar\n'
          '  subfoo2: subbar2\n'
          'other: maybe\n'
          'or:\n'
          '  status:\n'
          '    name: not\n';

      prepareTranslationList(todoList, loadYaml(yaml), root);
      todoList.sort((a, b) {
        return a.metadata.objectName.compareTo(b.metadata.objectName);
      });
      expect(todoList.length, equals(4));
      expect(todoList[0].metadata.objectName, equals('FooTest'));
      expect(todoList[1].metadata.objectName, equals('OrTest'));
      expect(todoList[2].metadata.objectName, equals('StatusOrTest'));
      expect(todoList[2].metadata.parent, equals(todoList[1].metadata));
      expect(todoList[2].metadata.parent?.parent, equals(todoList[3].metadata));
      expect(todoList[3].metadata.objectName, equals('Test'));
      expect(todoList[3].metadata.parent, isNull);
    });
  });
}

void testMeta(
  String name, {
  required bool isDefault,
  required String defaultObjectName,
  required String objectName,
  required String languageCode,
  required String localeName,
}) {
  final meta = generateMessageObjectName(name);
  test('$name: isDefault', () {
    expect(meta.isDefault, equals(isDefault));
  });
  test('$name: defaultObjectName', () {
    expect(meta.defaultObjectName, equals(defaultObjectName));
  });
  test('$name: objectName', () {
    expect(meta.objectName, equals(objectName));
  });
  test('$name: localeName', () {
    expect(meta.localeName, equals(localeName));
  });
  test('$name: languageCode', () {
    expect(meta.languageCode, equals(languageCode));
  });
}
