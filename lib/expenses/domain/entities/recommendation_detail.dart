import 'package:equatable/equatable.dart';

class RecommendationDetail extends Equatable {
  final int categoryId;
  final double currentLimit;
  final double suggestedLimit;

  const RecommendationDetail({
    required this.categoryId,
    required this.currentLimit,
    required this.suggestedLimit,
  });

  @override
  List<Object?> get props => [categoryId, currentLimit, suggestedLimit];
}