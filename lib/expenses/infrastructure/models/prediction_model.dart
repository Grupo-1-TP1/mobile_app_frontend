import 'package:mobile_app_frontend/expenses/domain/entities/prediction.dart';

class PredictionModel {
  final int? id;
  final double confidenceScore;
  final int categoryId;
  final String text;
  final int transactionId;

  const PredictionModel({
    this.id,
    required this.confidenceScore,
    required this.categoryId,
    required this.text,
    required this.transactionId,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      id: json['id'] as int?,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      categoryId: (json['categoryId'] as num).toInt(),
      text: json['text'] as String,
      transactionId: (json['transactionId'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'confidenceScore': confidenceScore,
      'categoryId': categoryId,
      'text': text,
      'transactionId': transactionId,
    };
  }

  Prediction toEntity() {
    return Prediction(
      id: id,
      confidenceScore: confidenceScore,
      categoryId: categoryId,
      text: text,
      transactionId: transactionId,
    );
  }

  factory PredictionModel.fromEntity(Prediction entity) {
    return PredictionModel(
      id: entity.id,
      confidenceScore: entity.confidenceScore,
      categoryId: entity.categoryId,
      text: entity.text,
      transactionId: entity.transactionId,
    );
  }
}