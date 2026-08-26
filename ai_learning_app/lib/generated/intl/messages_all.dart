// GENERATED CODE - DO NOT MODIFY BY HAND
// Intl Messages Aggregator
import 'messages_en.dart';
import 'messages_vi.dart';

class MessagesAll {
  MessagesAll._();

  static final Map<String, Map<String, String>> localizedValues = {
    'vi': messagesVi,
    'en': messagesEn,
  };

  static String lookup(String locale, String key) {
    return localizedValues[locale]?[key] ?? localizedValues['vi']?[key] ?? key;
  }
}
