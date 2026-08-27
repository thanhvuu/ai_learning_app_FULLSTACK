import 'package:flutter/material.dart';

enum LanguageCode {
  vi('vi', 'Tiếng Việt', '🇻🇳'),
  en('en', 'English', '🇺🇸');

  final String code;
  final String displayName;
  final String flag;

  const LanguageCode(this.code, this.displayName, this.flag);

  Locale get locale => Locale(code);

  static LanguageCode fromCode(String code) {
    return code == 'en' ? LanguageCode.en : LanguageCode.vi;
  }

  static LanguageCode fromString(String code) => fromCode(code);
}
