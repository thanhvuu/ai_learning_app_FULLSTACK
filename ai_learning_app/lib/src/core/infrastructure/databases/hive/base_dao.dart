import 'package:hive/hive.dart';
import 'package:ai_learning_app/src/core/domain/entities/base_entity.dart';
import 'database_service.dart';

abstract class BaseDao<T extends BaseEntity> {
  final String boxName;

  const BaseDao(this.boxName);

  Box<T> get box => DatabaseService.instance.getBox<T>(boxName);

  Future<List<T>> getAll({bool Function(T item)? filter}) async {
    final values = box.values.toList();
    if (filter != null) {
      return values.where(filter).toList();
    }
    return values;
  }

  Future<T?> getById(String id) async {
    return box.get(id);
  }

  Future<void> insertOne(T entity) async {
    await box.put(entity.id, entity);
  }

  Future<void> insertAll(List<T> entities) async {
    final map = {for (var entity in entities) entity.id: entity};
    await box.putAll(map);
  }

  Future<void> update(T entity) async {
    await box.put(entity.id, entity);
  }

  Future<void> delete(String id) async {
    await box.delete(id);
  }

  Future<void> clear() async {
    await box.clear();
  }

  int get count => box.length;

  bool get isEmpty => box.isEmpty;

  bool get isNotEmpty => box.isNotEmpty;

  Stream<BoxEvent> watch({dynamic key}) {
    return box.watch(key: key);
  }
}
