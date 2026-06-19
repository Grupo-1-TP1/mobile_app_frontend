import 'package:mobile_app_frontend/expenses/domain/entities/transaction.dart';

class TransactionModel {
  final int? id;
  final int userId;
  final int accountId;
  final int categoryId;
  final int? savingGoalId;
  final String type;
  final double amount;
  final String? description;
  final DateTime transactionDate;

  const TransactionModel({
    this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    this.savingGoalId,
    required this.type,
    required this.amount,
    this.description,
    required this.transactionDate,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int?,
      userId: (json['userId'] as num).toInt(),
      accountId: (json['accountId'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      savingGoalId: json['savingGoalId'] as int?,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'accountId': accountId,
      'categoryId': categoryId,
      'savingGoalId': savingGoalId,
      'type': type,
      'amount': amount,
      'description': description,
      'transactionDate': transactionDate.toIso8601String().split('T').first,
    };
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      savingGoalId: savingGoalId,
      type: type,
      amount: amount,
      description: description,
      transactionDate: transactionDate
    );
  }

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      accountId: entity.accountId,
      categoryId: entity.categoryId,
      savingGoalId: entity.savingGoalId,
      type: entity.type,
      amount: entity.amount,
      description: entity.description,
      transactionDate: entity.transactionDate,
    );
  }
}