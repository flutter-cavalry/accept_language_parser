import 'package:accept_language_parser/accept_language_parser.dart';

void main() async {
  var languages = parseAcceptLanguage('en-GB,en;q=0.8,fr-FR');
  print(languages);
  /**
    [
      {
          "c":"en",
          "s":null,
          "r":"GB",
          "q":1.0
      },
      {
          "c":"fr",
          "s":null,
          "r":"FR",
          "q":1.0
      },
      {
          "c":"en",
          "s":null,
          "r":null,
          "q":0.8
      }
    ]
   */

  var match1 = pickAcceptLanguage(['fr-CA', 'fr-FR', 'fr'], languages);
  print(match1);
  // fr-FR

  // Pick a language in loose mode.
  var match2 = pickAcceptLanguage(['en'], languages, loose: true);
  print(match2);
  // en
}
