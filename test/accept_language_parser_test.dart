import 'package:accept_language_parser/src/accept_language_parser.dart';
import 'package:test/test.dart';

void t(String s, List<Language> langs) async {
  // `equals` doesn't support deep object comparison. Convert params to string arrays instead.
  expect(parseAcceptLanguage(s).map((e) => e.toString()),
      equals(langs.map((e) => e.toString())));
}

void p(List<String> supported, String al, String? result,
    {bool? loose = false}) async {
  expect(pickAcceptLanguage(supported, parseAcceptLanguage(al), loose: loose),
      result);
}

void main() {
  group('parse', () {
    test('should correctly parse the language with quality', () {
      t('en-GB;q=0.8', [Language(code: 'en', region: 'GB', quality: 0.8)]);
    });

    test('should correctly parse the language without quality (default 1)', () {
      t('en-GB', [Language(code: 'en', region: 'GB')]);
    });

    test('should correctly parse the language without region', () {
      t('en;q=0.8', [Language(code: 'en', quality: 0.8)]);
    });

    test('should ignore extra characters in the region code', () {
      t('az-AZ', [Language(code: 'az', region: 'AZ')]);
    });

    test('should correctly parse a multi-language set', () {
      t('fr-CA,fr;q=0.8', [
        Language(code: 'fr', region: 'CA'),
        Language(code: 'fr', quality: 0.8)
      ]);
    });

    test('should correctly parse a wildcard', () {
      t('fr-CA,*;q=0.8', [
        Language(code: 'fr', region: 'CA'),
        Language(code: '*', quality: 0.8)
      ]);
    });

    test('should correctly parse a region with numbers', () {
      t('fr-150', [
        Language(code: 'fr', region: '150'),
      ]);
    });

    test('should correctly parse complex set', () {
      t('fr-CA,fr;q=0.8,en-US;q=0.6,en;q=0.4,*;q=0.1', [
        Language(
          code: 'fr',
          region: 'CA',
        ),
        Language(code: 'fr', quality: 0.8),
        Language(
          code: 'en',
          region: 'US',
          quality: 0.6,
        ),
        Language(code: 'en', quality: 0.4),
        Language(
          code: '*',
          quality: 0.1,
        ),
      ]);
    });

    test('should cope with random whitespace', () {
      t('fr-CA, fr;q=0.8,  en-US;q=0.6,en;q=0.4,    *;q=0.1', [
        Language(
          code: 'fr',
          region: 'CA',
        ),
        Language(code: 'fr', quality: 0.8),
        Language(code: 'en', region: 'US', quality: 0.6),
        Language(code: 'en', quality: 0.4),
        Language(code: '*', quality: 0.1),
      ]);
    });

    test('should sort based on quality value', () {
      t('fr-CA,fr;q=0.2,en-US;q=0.6,en;q=0.4,*;q=0.5', [
        Language(code: 'fr', region: 'CA'),
        Language(code: 'en', region: 'US', quality: 0.6),
        Language(code: '*', quality: 0.5),
        Language(code: 'en', quality: 0.4),
        Language(code: 'fr', quality: 0.2),
      ]);
    });

    test('should correctly identify script', () {
      t('zh-Hant-cn', [
        Language(
          code: 'zh',
          script: 'Hant',
          region: 'cn',
        ),
      ]);
    });

    test('should cope with script and a quality value', () {
      t('zh-Hant-cn;q=1, zh-cn;q=0.6, zh;q=0.4', [
        Language(
          code: 'zh',
          script: 'Hant',
          region: 'cn',
        ),
        Language(code: 'zh', region: 'cn', quality: 0.6),
        Language(code: 'zh', quality: 0.4),
      ]);
    });
  });

  group('pick', () {
    test('should pick a specific regional language', () {
      p(['en-US', 'fr-CA'], 'fr-CA,fr;q=0.2,en-US;q=0.6,en;q=0.4,*;q=0.5',
          'fr-CA');
    });

    test(
        'should pick a specific regional language when accept-language is parsed',
        () {
      p(['en-US', 'fr-CA'], 'fr-CA,fr;q=0.2,en-US;q=0.6,en;q=0.4,*;q=0.5',
          'fr-CA');
    });

    test('should pick a specific script (if specified)', () {
      p(['zh-Hant-cn', 'zh-cn'], 'zh-Hant-cn,zh-cn;q=0.6,zh;q=0.4',
          'zh-Hant-cn');
    });

    test('should pick proper language regardless of casing', () {
      p(['eN-Us', 'Fr-cA'], 'fR-Ca,fr;q=0.2,en-US;q=0.6,en;q=0.4,*;q=0.5',
          'Fr-cA');
    });

    test('should pick a specific language', () {
      p(['en', 'fr-CA'], 'ja-JP,ja;1=0.5,en;q=0.2', 'en');
    });

    test('should pick a language when culture is not specified', () {
      p(['en-us', 'it-IT'], 'pl-PL,en', 'en-us');
    });

    test('should return null if no matches are found', () {
      p(['ko-KR'], 'fr-CA,fr;q=0.8,en-US;q=0.6,en;q=0.4,*;q=0.1', null);
    });

    test('should return null if support no languages', () {
      p([], 'fr-CA,fr;q=0.8,en-US;q=0.6,en;q=0.4,*;q=0.1', null);
    });

    test('should return null if invalid support', () {
      p([], 'fr-CA,fr;q=0.8,en-US;q=0.6,en;q=0.4,*;q=0.1', null);
    });

    test('should return null if invalid accept-language', () {
      p(['en'], '', null);
    });

    test('by default should be strict when selecting language', () {
      p(['en', 'pl'], 'en-US;q=0.6', null);
    });

    test('can select language loosely with an option', () {
      p(['en', 'pl'], 'en-US;q=0.6', 'en', loose: true);
    });

    test('selects most matching language in loose mode', () {
      p(['en-US', 'en', 'pl'], 'en-US;q=0.6', 'en-US', loose: true);
    });
  });
}
