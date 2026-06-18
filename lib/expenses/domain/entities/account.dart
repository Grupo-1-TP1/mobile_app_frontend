import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final int? id;
  final int userId;
  final String name;
  final double balance;
  final double availableBalance;
  final double savingsFund;
  final int savingPercentage;

  const Account({
    this.id,
    required this.userId,
    required this.name,
    required this.balance,
    this.availableBalance = 0.0,
    this.savingsFund = 0.0,
    this.savingPercentage = 0,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    final double totalBalance = (json['balance'] as num).toDouble();
    return Account(
      id: json['id'] as int?,
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      balance: totalBalance,
      availableBalance: json['availableBalance'] != null
          ? (json['availableBalance'] as num).toDouble()
          : totalBalance, 
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

  Account copyWith({
    int? id,
    int? userId,
    String? name,
    double? balance,
    double? availableBalance,
    double? savingsFund,
    int? savingPercentage,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      availableBalance: availableBalance ?? this.availableBalance,
      savingsFund: savingsFund ?? this.savingsFund,
      savingPercentage: savingPercentage ?? this.savingPercentage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    balance,
    availableBalance,
    savingsFund,
    savingPercentage,
  ];
}
