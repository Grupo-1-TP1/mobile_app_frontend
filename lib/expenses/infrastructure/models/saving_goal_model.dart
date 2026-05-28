import 'package:mobile_app_frontend/expenses/domain/entities/saving_goal.dart';

class SavingGoalModel {
  final int? id;
  final int userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;

  const SavingGoalModel({
    this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
  });

  factory SavingGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingGoalModel(
      id: json['id'] as int?,
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      deadline: DateTime.parse(json['deadline'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String().split('T').first,
    };
  }

  SavingGoal toEntity() {
    return SavingGoal(
      id: id,
      userId: userId,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
    );
  }

  factory SavingGoalModel.fromEntity(SavingGoal entity) {
    return SavingGoalModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      deadline: entity.deadline,
    );
  }
}