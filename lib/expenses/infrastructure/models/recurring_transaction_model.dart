import 'package:mobile_app_frontend/expenses/domain/entities/recurring_transaction.dart';

class RecurringTransactionModel {
  final int? id;
  final int userId;
  final int accountId;
  final int categoryId;
  final String type;
  final double amount;
  final String? description;
  final String frequency;
  final DateTime nextExecutionDate;

  const RecurringTransactionModel({
    this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.description,
    required this.frequency,
    required this.nextExecutionDate,
  });

  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionModel(
      id: json['id'] as int?,
      userId: (json['userId'] as num).toInt(),
      accountId: (json['accountId'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      frequency: json['frequency'] as String,
      nextExecutionDate: DateTime.parse(json['nextExecutionDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'accountId': accountId,
      'categoryId': categoryId,
      'type': type,
      'amount': amount,
      'description': description,
      'frequency': frequency,
      'nextExecutionDate': nextExecutionDate.toIso8601String().split('T').first,
    };
  }

  RecurringTransaction toEntity() {
    return RecurringTransaction(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      description: description,
      frequency: frequency,
      nextExecutionDate: nextExecutionDate,
    );
  }

  factory RecurringTransactionModel.fromEntity(RecurringTransaction entity) {
    return RecurringTransactionModel(
      id: entity.id,
      userId: entity.userId,
      accountId: entity.accountId,
      categoryId: entity.categoryId,
      type: entity.type,
      amount: entity.amount,
      description: entity.description,
      frequency: entity.frequency,
      nextExecutionDate: entity.nextExecutionDate,
    );
  }
}