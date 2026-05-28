import 'package:mobile_app_frontend/expenses/domain/entities/account.dart';

class AccountModel {
  final int? id;
  final int userId;
  final String name;
  final double balance;

  const AccountModel({
    this.id,
    required this.userId,
    required this.name,
    required this.balance,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int?,
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'name': name,
      'balance': balance,
    };
  }

  Account toEntity() {
    return Account(
      id: id,
      userId: userId,
      name: name,
      balance: balance,
    );
  }

  factory AccountModel.fromEntity(Account entity) {
    return AccountModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      balance: entity.balance,
    );
  }
}