import 'package:mobile_app_frontend/expenses/domain/entities/budget.dart';
import 'package:mobile_app_frontend/expenses/domain/repositories/expenses_repository.dart';

class BudgetService {
  final ExpensesRepository repository;

  BudgetService(this.repository);

  Future<List<Budget>> getBudgetsByUserId(int userId) {
    return repository.getBudgetsByUserId(userId);
  }

  Future<Budget> createBudget(Budget budget) {
    return repository.createBudget(budget);
  }

  Future<Budget> getBudgetById(int budgetId) {
    return repository.getBudgetById(budgetId);
  }

  Future<void> deleteBudget(int budgetId) {
    return repository.deleteBudget(budgetId);
  }
}