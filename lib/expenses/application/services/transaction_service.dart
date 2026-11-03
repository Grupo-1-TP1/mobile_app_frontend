import 'package:mobile_app_frontend/expenses/domain/entities/transaction.dart';
import 'package:mobile_app_frontend/expenses/domain/repositories/expenses_repository.dart';

class TransactionService {
  final ExpensesRepository repository;

  TransactionService(this.repository);

  Future<List<Transaction>> getTransactionsByUserId(int userId) {
    return repository.getTransactionsByUserId(userId);
  }

  Future<Transaction> createTransaction(Transaction transaction) {
    return repository.createTransaction(transaction);
  }

  Future<Transaction> updateTransaction(
    int transactionId,
    int categoryId,
    double amount,
    String description,
  ) {
    return repository.updateTransaction(
      transactionId,
      categoryId,
      amount,
      description,
    );
  }

  Future<void> deleteTransaction(int transactionId) {
    return repository.deleteTransaction(transactionId);
  }

  Future<List<Transaction>> getTransactionsByUserIdAndMonthAndYear(int userId, int month, int year) {
    return repository.getTransactionsByUserIdAndMonthAndYear(userId, month, year);
  }
}