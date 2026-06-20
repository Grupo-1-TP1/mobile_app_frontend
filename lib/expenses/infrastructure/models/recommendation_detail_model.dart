import 'package:mobile_app_frontend/expenses/domain/entities/recommendation_detail.dart';

class RecommendationDetailModel {
  final int categoryId;
  final double currentLimit;
  final double suggestedLimit;

  const RecommendationDetailModel({
    required this.categoryId,
    required this.currentLimit,
    required this.suggestedLimit,
  });

  factory RecommendationDetailModel.fromJson(Map<String, dynamic> json) {
    return RecommendationDetailModel(
      categoryId: (json['categoryId'] as num).toInt(),
      currentLimit: (json['currentLimit'] as num).toDouble(),
      suggestedLimit: (json['suggestedLimit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'currentLimit': currentLimit,
      'suggestedLimit': suggestedLimit,
    };
  }

  RecommendationDetail toEntity() {
    return RecommendationDetail(
      categoryId: categoryId,
      currentLimit: currentLimit,
      suggestedLimit: suggestedLimit,
    );
  }

  factory RecommendationDetailModel.fromEntity(RecommendationDetail entity) {
    return RecommendationDetailModel(
      categoryId: entity.categoryId,
      currentLimit: entity.currentLimit,
      suggestedLimit: entity.suggestedLimit,
    );
  }
}