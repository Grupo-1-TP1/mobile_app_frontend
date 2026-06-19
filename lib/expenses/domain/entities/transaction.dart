import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int? id;
  final int userId;
  final int accountId;
  final int categoryId;
  final int? savingGoalId;
  final String type;
  final double amount;
  final String? description;
  final DateTime transactionDate;

  const Transaction({
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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
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

  Transaction copyWith({
    int? id,
    int? userId,
    int? accountId,
    int? categoryId,
    int? savingGoalId,
    String? type,
    double? amount,
    String? description,
    DateTime? transactionDate,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      savingGoalId: savingGoalId ?? this.savingGoalId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        accountId,
        categoryId,
        savingGoalId,
        type,
        amount,
        description,
        transactionDate,
      ];
}