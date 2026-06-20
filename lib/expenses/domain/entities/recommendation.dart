import 'package:equatable/equatable.dart';
import 'recommendation_detail.dart';

class Recommendation extends Equatable {
  final int? id;
  final int userId;
  final double projectedSavings;
  final List<RecommendationDetail> details;

  const Recommendation({
    this.id,
    required this.userId,
    required this.projectedSavings,
    required this.details,
  });

  @override
  List<Object?> get props => [id, userId, projectedSavings, details];
}