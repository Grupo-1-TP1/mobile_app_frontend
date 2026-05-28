import 'package:mobile_app_frontend/expenses/domain/entities/account.dart';
import 'package:mobile_app_frontend/expenses/domain/repositories/expenses_repository.dart';

class AccountService {
  final ExpensesRepository repository;

  AccountService(this.repository);

  Future<List<Account>> getAccountsByUserId(int userId) {
    return repository.getAccountsByUserId(userId);
  }

  Future<Account> createAccount(Account account) {
    return repository.createAccount(account);
  }

  Future<Account> getAccountById(int accountId) {
    return repository.getAccountById(accountId);
  }

  Future<void> deleteAccount(int accountId) {
    return repository.deleteAccount(accountId);
  }
}