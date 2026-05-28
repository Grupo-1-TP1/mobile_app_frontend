import 'package:mobile_app_frontend/expenses/domain/entities/account.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/budget.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/recurring_transaction.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/saving_goal.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/transaction.dart';
import 'package:mobile_app_frontend/expenses/domain/repositories/expenses_repository.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/data_sources/expenses_remote_data_source.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/account_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/budget_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/category_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/recurring_transaction_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/saving_goal_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/transaction_model.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesRemoteDataSource remoteDataSource;

  ExpensesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Account>> getAccountsByUserId(int userId) async {
    final models = await remoteDataSource.getAccountsByUserId(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Account> createAccount(Account account) async {
    final model = await remoteDataSource.createAccount(AccountModel.fromEntity(account));
    return model.toEntity();
  }

  @override
  Future<Account> getAccountById(int accountId) async {
    final model = await remoteDataSource.getAccountById(accountId);
    return model.toEntity();
  }

  @override
  Future<void> deleteAccount(int accountId) {
    return remoteDataSource.deleteAccount(accountId);
  }

  @override
  Future<List<Category>> getCategories() async {
    final models = await remoteDataSource.getCategories();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Category> createCategory(Category category) async {
    final model = await remoteDataSource.createCategory(CategoryModel.fromEntity(category));
    return model.toEntity();
  }

  @override
  Future<Category> getCategoryById(int categoryId) async {
    final model = await remoteDataSource.getCategoryById(categoryId);
    return model.toEntity();
  }

  @override
  Future<void> deleteCategory(int categoryId) {
    return remoteDataSource.deleteCategory(categoryId);
  }

  @override
  Future<List<Transaction>> getTransactionsByUserId(int userId) async {
    final models = await remoteDataSource.getTransactionsByUserId(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    final model = await remoteDataSource.createTransaction(TransactionModel.fromEntity(transaction));
    return model.toEntity();
  }

  @override
  Future<void> deleteTransaction(int transactionId) {
    return remoteDataSource.deleteTransaction(transactionId);
  }

  @override
  Future<List<RecurringTransaction>> getRecurringTransactionsByUserId(int userId) async {
    final models = await remoteDataSource.getRecurringTransactionsByUserId(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<RecurringTransaction> createRecurringTransaction(RecurringTransaction transaction) async {
    final model = await remoteDataSource.createRecurringTransaction(
      RecurringTransactionModel.fromEntity(transaction),
    );
    return model.toEntity();
  }

  @override
  Future<RecurringTransaction> getRecurringTransactionById(int recurringTransactionId) async {
    final model = await remoteDataSource.getRecurringTransactionById(recurringTransactionId);
    return model.toEntity();
  }

  @override
  Future<void> deleteRecurringTransaction(int recurringTransactionId) {
    return remoteDataSource.deleteRecurringTransaction(recurringTransactionId);
  }

  @override
  Future<List<Budget>> getBudgetsByUserId(int userId) async {
    final models = await remoteDataSource.getBudgetsByUserId(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Budget> createBudget(Budget budget) async {
    final model = await remoteDataSource.createBudget(BudgetModel.fromEntity(budget));
    return model.toEntity();
  }

  @override
  Future<Budget> getBudgetById(int budgetId) async {
    final model = await remoteDataSource.getBudgetById(budgetId);
    return model.toEntity();
  }

  @override
  Future<void> deleteBudget(int budgetId) {
    return remoteDataSource.deleteBudget(budgetId);
  }

  @override
  Future<List<SavingGoal>> getSavingGoalsByUserId(int userId) async {
    final models = await remoteDataSource.getSavingGoalsByUserId(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<SavingGoal> createSavingGoal(SavingGoal savingGoal) async {
    final model = await remoteDataSource.createSavingGoal(SavingGoalModel.fromEntity(savingGoal));
    return model.toEntity();
  }

  @override
  Future<SavingGoal> getSavingGoalById(int savingGoalId) async {
    final model = await remoteDataSource.getSavingGoalById(savingGoalId);
    return model.toEntity();
  }

  @override
  Future<void> deleteSavingGoal(int savingGoalId) {
    return remoteDataSource.deleteSavingGoal(savingGoalId);
  }
}