import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final int? id;
  final int userId;
  final String name;
  final double balance;

  const Account({
    this.id,
    required this.userId,
    required this.name,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
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

  Account copyWith({
    int? id,
    int? userId,
    String? name,
    double? balance,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, balance];
}