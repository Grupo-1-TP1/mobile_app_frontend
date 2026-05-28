import 'package:mobile_app_frontend/expenses/domain/entities/recurring_transaction.dart';
import 'package:mobile_app_frontend/expenses/domain/repositories/expenses_repository.dart';

class RecurringTransactionService {
  final ExpensesRepository repository;

  RecurringTransactionService(this.repository);

  Future<List<RecurringTransaction>> getRecurringTransactionsByUserId(int userId) {
    return repository.getRecurringTransactionsByUserId(userId);
  }

  Future<RecurringTransaction> createRecurringTransaction(RecurringTransaction transaction) {
    return repository.createRecurringTransaction(transaction);
  }

  Future<RecurringTransaction> getRecurringTransactionById(int recurringTransactionId) {
    return repository.getRecurringTransactionById(recurringTransactionId);
  }

  Future<void> deleteRecurringTransaction(int recurringTransactionId) {
    return repository.deleteRecurringTransaction(recurringTransactionId);
  }
}