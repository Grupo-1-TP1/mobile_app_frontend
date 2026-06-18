import 'package:mobile_app_frontend/expenses/domain/entities/account.dart';

class AccountModel {
  final int? id;
  final int userId;
  final String name;
  final double balance;
  final double availableBalance;
  final double savingsFund;
  final int savingPercentage;

  const AccountModel({
    this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.availableBalance,
    required this.savingsFund,
    required this.savingPercentage,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final double baseBalance = (json['balance'] as num).toDouble();
    return AccountModel(
      id: json['id'] as int?,
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      balance: baseBalance,
      availableBalance: json['availableBalance'] != null
          ? (json['availableBalance'] as num).toDouble()
          : baseBalance,
      savingsFund: json['savingsFund'] != null
          ? (json['savingsFund'] as num).toDouble()
          : 0.0,
      savingPercentage: json['savingPercentage'] != null
          ? (json['savingPercentage'] as num).toInt()
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'name': name,
      'balance': balance,
      'availableBalance': availableBalance,
      'savingsFund': savingsFund,
      'savingPercentage': savingPercentage,
    };
  }

  Account toEntity() {
    return Account(
      id: id,
      userId: userId,
      name: name,
      balance: balance,
      availableBalance: availableBalance,
      savingsFund: savingsFund,
      savingPercentage: savingPercentage,
    );
  }

  factory AccountModel.fromEntity(Account entity) {
    return AccountModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      balance: entity.balance,
      availableBalance: entity.availableBalance,
      savingsFund: entity.savingsFund,
      savingPercentage: entity.savingPercentage,
    );
  }
}
