// ignore_for_file: avoid_print

import 'package:accept_language_parser/accept_language_parser.dart';

void main() async {
  final languages = parseAcceptLanguage('en-GB,en;q=0.8,fr-FR');
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

  final match1 = pickAcceptLanguage(['fr-CA', 'fr-FR', 'fr'], languages);
  print(match1);
  // fr-FR

  // Pick a language in loose mode.
  final match2 = pickAcceptLanguage(['en'], languages, loose: true);
  print(match2);
  // en
}
