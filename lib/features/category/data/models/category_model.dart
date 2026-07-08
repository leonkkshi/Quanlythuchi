import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.iconCode,
    required super.colorHex,
    required super.userId,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      iconCode: map['icon_code'] as int,
      colorHex: map['color_hex'] as String,
      userId: map['user_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon_code': iconCode,
      'color_hex': colorHex,
      'user_id': userId,
    };
  }
}
