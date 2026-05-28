import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final int? id;
  final int userId;
  final int categoryId;
  final double amount;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;

  const Budget({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.spent,
    required this.startDate,
    required this.endDate,
  });

  double get remainingAmount => amount - spent;
  double get progress => amount == 0 ? 0 : spent / amount;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as int?,
      userId: (json['userId'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'amount': amount,
      'startDate': startDate.toIso8601String().split('T').first,
      'endDate': endDate.toIso8601String().split('T').first,
      'spent': spent,
    };
  }

  Budget copyWith({
    int? id,
    int? userId,
    int? categoryId,
    double? amount,
    double? spent,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        amount,
        spent,
        startDate,
        endDate,
      ];
}