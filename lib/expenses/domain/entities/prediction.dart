import 'package:equatable/equatable.dart';

class Prediction extends Equatable {
  final int? id;
  final double confidenceScore;
  final int categoryId;
  final String text;
  final int transactionId;

  const Prediction({
    this.id,
    required this.confidenceScore,
    required this.categoryId,
    required this.text,
    required this.transactionId,
  });

  @override
  List<Object?> get props => [id, confidenceScore, categoryId, text, transactionId];
}