import 'package:mobile_app_frontend/expenses/domain/entities/recommendation.dart';
import 'recommendation_detail_model.dart';

class RecommendationModel {
  final int? id;
  final int userId;
  final double projectedSavings;
  final List<RecommendationDetailModel> details;

  const RecommendationModel({
    this.id,
    required this.userId,
    required this.projectedSavings,
    required this.details,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    final detailsList = json['details'] as List<dynamic>? ?? [];
    final parsedDetails = detailsList
        .map((d) => RecommendationDetailModel.fromJson(d as Map<String, dynamic>))
        .toList();

    return RecommendationModel(
      id: json['id'] as int?,
      userId: (json['userId'] as num).toInt(),
      projectedSavings: (json['projectedSavings'] as num).toDouble(),
      details: parsedDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'projectedSavings': projectedSavings,
      'details': details.map((d) => d.toJson()).toList(),
    };
  }

  Recommendation toEntity() {
    return Recommendation(
      id: id,
      userId: userId,
      projectedSavings: projectedSavings,
      details: details.map((d) => d.toEntity()).toList(),
    );
  }

  factory RecommendationModel.fromEntity(Recommendation entity) {
    return RecommendationModel(
      id: entity.id,
      userId: entity.userId,
      projectedSavings: entity.projectedSavings,
      details: entity.details
          .map((d) => RecommendationDetailModel.fromEntity(d))
          .toList(),
    );
  }
}