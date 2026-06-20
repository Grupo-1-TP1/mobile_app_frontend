import 'package:mobile_app_frontend/expenses/domain/entities/prediction.dart';
import 'package:mobile_app_frontend/expenses/domain/repositories/expenses_repository.dart';

class PredictionService {
  final ExpensesRepository repository;
  PredictionService(this.repository);

  Future<Prediction> createPrediction(Prediction prediction) {
    return repository.createPrediction(prediction);
  }
}