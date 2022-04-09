import 'package:accept_language_parser/src/accept_language_parser.dart';
import 'package:test/test.dart';

void t(String s, List<Language> langs) async {
  // `equals` doesn't support deep object comparison. Convert params to string arrays instead.
  expect(parseAcceptLanguage(s).map((e) => e.toString()),
      equals(langs.map((e) => e.toString())));
}

void main() {
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
}
