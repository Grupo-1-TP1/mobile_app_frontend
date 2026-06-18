import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final int? id;
  final int userId;
  final int categoryId;
  final double amount;
  final double spent;
  final DateTime date;

  const Budget({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.spent,
    required this.date,
  });

  double get remainingAmount => amount - spent;
  double get progress => amount == 0 ? 0 : spent / amount;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as int?,
      userId: (json['userId'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      // 'spent' viene del backend al consultar, si no viene (o es nulo) por defecto es 0.0
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] as String),
    );
  }

  // MODIFICADO: Retorna exactamente lo que tu POST del backend necesita
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'amount': amount,
      // Se envía formateado en formato estricto YYYY-MM-DD
      'date': date.toIso8601String().split('T').first,
    };
  }

  // CORREGIDO: Se eliminaron startDate/endDate obsoletos y se usa 'date'
  Budget copyWith({
    int? id,
    int? userId,
    int? categoryId,
    double? amount,
    double? spent,
    DateTime? date,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        amount,
        spent,
        date,
      ];
}