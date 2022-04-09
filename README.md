[![pub package](https://img.shields.io/pub/v/accept_language_parser.svg)](https://pub.dev/packages/accept_language_parser)
[![Build Status](https://github.com/mgenware/accept_language_parser/workflows/Build/badge.svg)](https://github.com/mgenware/accept_language_parser/actions)

Dart port of [accept-language-parser](https://github.com/opentable/accept-language-parser).

## Usage

Install and import this package:

```sh
import 'package:accept_language_parser/accept_language_parser.dart';
```

Example:

```dart
import 'package:accept_language_parser/accept_language_parser.dart';

void main() async {
  print(parseAcceptLanguage('zh-Hans').toString());
}
```
