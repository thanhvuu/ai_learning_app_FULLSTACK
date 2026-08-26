enum LanguageCode {
  vi('vi', 'Tiếng Việt', '🇻🇳'),
  en('en', 'English', '🇺🇸');

  final String code;
  final String displayName;
  final String flag;

  const LanguageCode(this.code, this.displayName, this.flag);

  static LanguageCode fromCode(String code) {
    return code == 'en' ? LanguageCode.en : LanguageCode.vi;
  }
}
