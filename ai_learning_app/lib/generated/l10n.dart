import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ai_learning_app/src/core/application/language_provider.dart';
import 'intl/messages_all.dart';

class S {
  final String locale;

  const S(this.locale);

  static String _currentLocale = 'vi';

  static void setCurrentLocale(String locale) {
    _currentLocale = locale;
  }

  static const List<Locale> supportedLocales = [
    Locale('vi', 'VN'),
    Locale('en', 'US'),
    Locale('vi', ''),
    Locale('en', ''),
  ];

  static const LocalizationsDelegate<S> delegate = _AppLocalizationDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static String of(BuildContext context, String key) {
    try {
      final lang = Provider.of<LanguageProvider>(context, listen: false).languageCode;
      _currentLocale = lang;
      return MessagesAll.lookup(lang, key);
    } catch (_) {
      return MessagesAll.lookup(_currentLocale, key);
    }
  }

  static String get(String key) {
    return MessagesAll.lookup(_currentLocale, key);
  }

  static S get current => S(_currentLocale);

  String translate(String key) {
    return MessagesAll.lookup(locale, key);
  }
}

class _AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) async {
    S.setCurrentLocale(locale.languageCode);
    return S(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}
