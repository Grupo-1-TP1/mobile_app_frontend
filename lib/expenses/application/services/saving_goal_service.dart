import 'package:mobile_app_frontend/expenses/domain/entities/saving_goal.dart';
import 'package:mobile_app_frontend/expenses/domain/repositories/expenses_repository.dart';

class SavingGoalService {
  final ExpensesRepository repository;

  SavingGoalService(this.repository);

  Future<List<SavingGoal>> getSavingGoalsByUserId(int userId) {
    return repository.getSavingGoalsByUserId(userId);
  }

  Future<SavingGoal> createSavingGoal(SavingGoal savingGoal) {
    return repository.createSavingGoal(savingGoal);
  }

  Future<SavingGoal> getSavingGoalById(int savingGoalId) {
    return repository.getSavingGoalById(savingGoalId);
  }

  Future<void> deleteSavingGoal(int savingGoalId) {
    return repository.deleteSavingGoal(savingGoalId);
  }
}