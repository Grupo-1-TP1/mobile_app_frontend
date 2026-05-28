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

  Future<void> deleteTransaction(int transactionId) {
    return repository.deleteTransaction(transactionId);
  }
}