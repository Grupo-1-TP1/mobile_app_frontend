import 'package:mobile_app_frontend/expenses/domain/entities/recommendation.dart';
import 'package:mobile_app_frontend/expenses/domain/repositories/expenses_repository.dart';

class RecommendationService {
  final ExpensesRepository repository;
  RecommendationService(this.repository);

  Future<Recommendation> createRecommendation(Recommendation recommendation) {
    return repository.createRecommendation(recommendation);
  }
}