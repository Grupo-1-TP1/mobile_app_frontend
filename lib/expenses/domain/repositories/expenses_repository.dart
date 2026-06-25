import 'package:mobile_app_frontend/expenses/domain/entities/account.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/budget.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/prediction.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/recommendation.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/recurring_transaction.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/saving_goal.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/transaction.dart';

abstract class ExpensesRepository {
  Future<List<Account>> getAccountsByUserId(int userId);
  Future<Account> createAccount(Account account);
  Future<Account> getAccountById(int accountId);
  Future<void> deleteAccount(int accountId);

  Future<List<Category>> getCategories();
  Future<Category> createCategory(Category category);
  Future<Category> getCategoryById(int categoryId);
  Future<void> deleteCategory(int categoryId);

  Future<List<Transaction>> getTransactionsByUserId(int userId);
  Future<Transaction> createTransaction(Transaction transaction);
  Future<void> deleteTransaction(int transactionId);
  Future<List<Transaction>> getTransactionsByUserIdAndMonthAndYear(int userId, int month, int year);

  Future<List<RecurringTransaction>> getRecurringTransactionsByUserId(int userId);
  Future<RecurringTransaction> createRecurringTransaction(RecurringTransaction transaction);
  Future<RecurringTransaction> getRecurringTransactionById(int recurringTransactionId);
  Future<void> deleteRecurringTransaction(int recurringTransactionId);

  Future<List<Budget>> getBudgetsByUserId(int userId);
  Future<Budget> createBudget(Budget budget);
  Future<Budget> getBudgetById(int budgetId);
  Future<void> deleteBudget(int budgetId);
  Future<List<Budget>> getBudgetByUserIdAndMonthAndYear(int userId, int month, int year);

  Future<List<SavingGoal>> getSavingGoalsByUserId(int userId);
  Future<SavingGoal> createSavingGoal(SavingGoal savingGoal);
  Future<SavingGoal> getSavingGoalById(int savingGoalId);
  Future<void> deleteSavingGoal(int savingGoalId);

  Future<Prediction> createPrediction(Prediction prediction);
  Future<Recommendation> createRecommendation(Recommendation recommendation);
}