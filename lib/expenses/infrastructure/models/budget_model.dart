import 'package:mobile_app_frontend/expenses/domain/entities/budget.dart';

class BudgetModel {
  final int? id;
  final int userId;
  final int categoryId;
  final double amount;
  final double spent;
  final DateTime date;

  const BudgetModel({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.spent,
    required this.date,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as int?,
      userId: (json['userId'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toIso8601String().split('T').first,
    };
  }

  Budget toEntity() {
    return Budget(
      id: id,
      userId: userId,
      categoryId: categoryId,
      amount: amount,
      spent: spent,
      date: date,
    );
  }

  factory BudgetModel.fromEntity(Budget entity) {
    return BudgetModel(
      id: entity.id,
      userId: entity.userId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      spent: entity.spent,
      date: entity.date,
    );
  }

}
