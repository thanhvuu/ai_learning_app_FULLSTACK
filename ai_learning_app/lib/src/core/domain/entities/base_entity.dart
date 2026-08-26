abstract class BaseEntity {
  String get id;

  const BaseEntity();

  Map<String, dynamic> toJson();
}
