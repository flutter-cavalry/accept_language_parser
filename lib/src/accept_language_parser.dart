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
    var encoder = JsonEncoder();
    return encoder.convert({'c': code, 's': script, 'r': region, 'q': quality});
  }
}

List<Language> parseAcceptLanguage(String? al) {
  var strings = regex.allMatches(al ?? '');
  var langs = strings
      .map((m) {
        var str = m.group(0);
        if (str == null || str.isEmpty) {
          return null;
        }
        var bits = str.split(';');
        if (bits.isEmpty) {
          return null;
        }
        var ietf = bits[0].split('-');
        var hasScript = ietf.length == 3;

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

class PickOptions {
  final bool? loose;
  PickOptions({this.loose});
}

String? pickAcceptLanguage(List<String> supportedLanguages,
    List<Language> acceptLanguage, PickOptions? options) {
  if (supportedLanguages.isEmpty || acceptLanguage.isEmpty) {
    return null;
  }
  var supported = supportedLanguages.map((support) {
    var bits = support.split('-');
    var hasScript = bits.length == 3;

    return Language(
        code: bits[0],
        script: hasScript ? bits.tryGet(1) : null,
        region: hasScript ? bits.tryGet(2) : bits.tryGet(1));
  }).toList();

  for (var i = 0; i < acceptLanguage.length; i++) {
    var lang = acceptLanguage[i];
    var langCode = lang.code.toLowerCase();
    var langRegion = lang.region?.toLowerCase();
    var langScript = lang.script?.toLowerCase();
    for (var j = 0; j < supported.length; j++) {
      var supportedCode = supported[j].code.toLowerCase();
      var supportedScript = supported[j].script?.toLowerCase();
      var supportedRegion = supported[j].region?.toLowerCase();
      if (langCode == supportedCode &&
          (options?.loose == true ||
              (langScript?.isEmpty ?? true) ||
              langScript == supportedScript) &&
          (options?.loose == true ||
              (langRegion?.isEmpty ?? true) ||
              langRegion == supportedRegion)) {
        return supportedLanguages[j];
      }
    }
  }

  return null;
}
