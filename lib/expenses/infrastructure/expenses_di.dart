import 'package:mobile_app_frontend/expenses/application/services/account_service.dart';
import 'package:mobile_app_frontend/expenses/application/services/budget_service.dart';
import 'package:mobile_app_frontend/expenses/application/services/category_service.dart';
import 'package:mobile_app_frontend/expenses/application/services/recurring_transaction_service.dart';
import 'package:mobile_app_frontend/expenses/application/services/saving_goal_service.dart';
import 'package:mobile_app_frontend/expenses/application/services/transaction_service.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/data_sources/expenses_remote_data_source.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/repositories/expenses_repository_impl.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/data_sources/user_local_data_source.dart';

class ExpensesDI {
  static final userLocalDataSource = LocalUserDataSource();

  static final remoteDataSource = ExpensesRemoteDataSource(
    baseUrl: 'http://localhost:8080',
    getAuthToken: userLocalDataSource.getAuthToken,
  );

  static final repository = ExpensesRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );

  static final accountService = AccountService(repository);
  static final categoryService = CategoryService(repository);
  static final transactionService = TransactionService(repository);
  static final recurringTransactionService = RecurringTransactionService(repository);
  static final budgetService = BudgetService(repository);
  static final savingGoalService = SavingGoalService(repository);
}