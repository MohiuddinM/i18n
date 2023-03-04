import 'package:i18n/src/string_ext.dart';
import 'package:test/test.dart';

void main() => group('StringX', () {
      test('firstUpper should convert first character to uppercase', () {
        expect('string'.firstUpper(), 'String');
        expect('1string'.firstUpper(), '1string');
      });

      test('firstLower should convert first character to lowercase', () {
        expect('String'.firstLower(), 'string');
        expect('1String'.firstLower(), '1String');
      });

      test('containsReference return true if there is a reference', () {
        expect(r'$name'.containsReference, isTrue);
        expect(r'\$name'.containsReference, isFalse);
        expect(r'name'.containsReference, isFalse);
        expect(r'300\$'.containsReference, isFalse);
        expect(() => r'_\$$name'.containsReference, throwsArgumentError);
      });

      test('convert name works if there are no _ in the name', () {
        expect('message'.convertName(), 'message');
      });

      test('convert name works if there is 1 _ in the name', () {
        expect('message_de'.convertName(), 'messageDe');
      });

      test('convert name works if there are 2 _ in the name', () {
        expect('message_en_us'.convertName(), 'messageEnUs');
      });

      test('convert name works if there are many _ in the name', () {
        expect(
          'new_translation_message_en_us'.convertName(),
          'newTranslationMessageEnUs',
        );
      });
    });
