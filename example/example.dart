import 'package:accept_language_parser/accept_language_parser.dart';

void main() async {
  print(parseAcceptLanguage('zh-Hans').toString());
}
