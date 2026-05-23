import 'package:ai_learning_app/data/services/implements/dictionary_service_impl.dart';
import 'package:ai_learning_app/data/services/interfaces/dictionary_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final IDictionaryService dictionaryService = DictionaryServiceImpl();
}
