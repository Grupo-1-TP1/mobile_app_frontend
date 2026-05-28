import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String? description;

  const CategoryModel({
    this.id,
    required this.name,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
    };
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
    );
  }

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
    );
  }
}