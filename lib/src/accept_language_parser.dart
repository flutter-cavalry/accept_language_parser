import 'dart:convert';

var regex =
    RegExp('((([a-zA-Z]+(-[a-zA-Z0-9]+){0,2})|\\*)(;q=[0-1](\\.[0-9]+)?)?)*');

extension ListGetExtension<T> on List<T> {
  T? tryGet(int index) => index < 0 || index >= length ? null : this[index];
}

class Language {
  final String code;
  final String? script;
  final String? region;
  final double quality;

  Language({required this.code, this.script, this.region, this.quality = 1.0});

  @override
  String toString() {
    final encoder = JsonEncoder();
    return encoder.convert({'c': code, 's': script, 'r': region, 'q': quality});
  }
}

/// Parses the given "Accept-Language" header into an array of [Language].
List<Language> parseAcceptLanguage(String? al) {
  final strings = regex.allMatches(al ?? '');
  final langs = strings
      .map((m) {
        final str = m.group(0);
        if (str == null || str.isEmpty) {
          return null;
        }
        final bits = str.split(';');
        if (bits.isEmpty) {
          return null;
        }
        final ietf = bits[0].split('-');
        final hasScript = ietf.length == 3;

        return Language(
            code: ietf[0],
            script: hasScript ? ietf.tryGet(1) : null,
            region: hasScript ? ietf.tryGet(2) : ietf.tryGet(1),
            quality: bits.tryGet(1) != null
                ? (double.tryParse(
                        bits.tryGet(1)?.split('=').tryGet(1) ?? '') ??
                    1.0)
                : 1.0);
      })
      .whereType<Language>()
      .toList();
  langs.sort((a, b) => b.quality.compareTo(a.quality));
  return langs;
}

/// Finds the best match from a list of supported languages and preferred languages.
String? pickAcceptLanguage(
    List<String> supportedLanguages, List<Language> acceptLanguage,
    {bool? loose = false}) {
  if (supportedLanguages.isEmpty || acceptLanguage.isEmpty) {
    return null;
  }
  final supported = supportedLanguages.map((support) {
    final bits = support.split('-');
    final hasScript = bits.length == 3;

    return Language(
        code: bits[0],
        script: hasScript ? bits.tryGet(1) : null,
        region: hasScript ? bits.tryGet(2) : bits.tryGet(1));
  }).toList();

  for (var i = 0; i < acceptLanguage.length; i++) {
    final lang = acceptLanguage[i];
    final langCode = lang.code.toLowerCase();
    final langRegion = lang.region?.toLowerCase();
    final langScript = lang.script?.toLowerCase();
    for (var j = 0; j < supported.length; j++) {
      final supportedCode = supported[j].code.toLowerCase();
      final supportedScript = supported[j].script?.toLowerCase();
      final supportedRegion = supported[j].region?.toLowerCase();
      if (langCode == supportedCode &&
          (loose == true ||
              (langScript?.isEmpty ?? true) ||
              langScript == supportedScript) &&
          (loose == true ||
              (langRegion?.isEmpty ?? true) ||
              langRegion == supportedRegion)) {
        return supportedLanguages[j];
      }
    }
  }

  return null;
}
