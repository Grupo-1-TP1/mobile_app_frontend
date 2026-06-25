import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/expenses/infrastructure/models/account_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/budget_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/category_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/prediction_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/recommendation_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/recurring_transaction_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/saving_goal_model.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/models/transaction_model.dart';

class ExpensesRemoteDataSource {
  final String baseUrl;
  final http.Client client;
  final String? Function() getAuthToken;

  ExpensesRemoteDataSource({
    required this.baseUrl,
    required this.getAuthToken,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<AccountModel>> getAccountsByUserId(int userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/accounts/user/$userId'),
      headers: _authHeaders(),
    );
    return _readList(response, AccountModel.fromJson);
  }

  Future<AccountModel> createAccount(AccountModel model) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/accounts'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode(model.toJson()),
    );
    return _readSingle(response, AccountModel.fromJson);
  }

  Future<AccountModel> getAccountById(int accountId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/accounts/$accountId'),
      headers: _authHeaders(),
    );
    return _readSingle(response, AccountModel.fromJson);
  }

  Future<void> deleteAccount(int accountId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/accounts/$accountId'),
      headers: _authHeaders(),
    );
    _ensureSuccess(response);
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/categories'),
      headers: _authHeaders(),
    );
    return _readList(response, CategoryModel.fromJson);
  }

  Future<CategoryModel> createCategory(CategoryModel model) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/categories'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode(model.toJson()),
    );
    return _readSingle(response, CategoryModel.fromJson);
  }

  Future<CategoryModel> getCategoryById(int categoryId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/categories/$categoryId'),
      headers: _authHeaders(),
    );
    return _readSingle(response, CategoryModel.fromJson);
  }

  Future<void> deleteCategory(int categoryId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/categories/$categoryId'),
      headers: _authHeaders(),
    );
    _ensureSuccess(response);
  }

  Future<List<TransactionModel>> getTransactionsByUserId(int userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/transactions/user/$userId'),
      headers: _authHeaders(),
    );
    return _readList(response, TransactionModel.fromJson);
  }

  Future<TransactionModel> createTransaction(TransactionModel model) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/transactions'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode(model.toJson()),
    );
    return _readSingle(response, TransactionModel.fromJson);
  }

  Future<void> deleteTransaction(int transactionId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/transactions/$transactionId'),
      headers: _authHeaders(),
    );
    _ensureSuccess(response);
  }

  Future<List<RecurringTransactionModel>> getRecurringTransactionsByUserId(int userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/recurring-transactions/user/$userId'),
      headers: _authHeaders(),
    );
    return _readList(response, RecurringTransactionModel.fromJson);
  }

  Future<RecurringTransactionModel> createRecurringTransaction(RecurringTransactionModel model) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/recurring-transactions'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode(model.toJson()),
    );
    return _readSingle(response, RecurringTransactionModel.fromJson);
  }

  Future<RecurringTransactionModel> getRecurringTransactionById(int recurringTransactionId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/recurring-transactions/$recurringTransactionId'),
      headers: _authHeaders(),
    );
    return _readSingle(response, RecurringTransactionModel.fromJson);
  }

  Future<void> deleteRecurringTransaction(int recurringTransactionId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/recurring-transactions/$recurringTransactionId'),
      headers: _authHeaders(),
    );
    _ensureSuccess(response);
  }

  Future<List<BudgetModel>> getBudgetsByUserId(int userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/budgets/user/$userId'),
      headers: _authHeaders(),
    );
    return _readList(response, BudgetModel.fromJson);
  }

  Future<BudgetModel> createBudget(BudgetModel model) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/budgets'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode(model.toJson()),
    );
    return _readSingle(response, BudgetModel.fromJson);
  }

  Future<BudgetModel> getBudgetById(int budgetId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/budgets/$budgetId'),
      headers: _authHeaders(),
    );
    return _readSingle(response, BudgetModel.fromJson);
  }

  Future<void> deleteBudget(int budgetId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/budgets/$budgetId'),
      headers: _authHeaders(),
    );
    _ensureSuccess(response);
  }

  Future<List<SavingGoalModel>> getSavingGoalsByUserId(int userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/saving-goals/user/$userId'),
      headers: _authHeaders(),
    );
    return _readList(response, SavingGoalModel.fromJson);
  }

  Future<SavingGoalModel> createSavingGoal(SavingGoalModel model) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/saving-goals'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode(model.toJson()),
    );
    return _readSingle(response, SavingGoalModel.fromJson);
  }

  Future<SavingGoalModel> getSavingGoalById(int savingGoalId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/saving-goals/$savingGoalId'),
      headers: _authHeaders(),
    );
    return _readSingle(response, SavingGoalModel.fromJson);
  }

  Future<void> deleteSavingGoal(int savingGoalId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/saving-goals/$savingGoalId'),
      headers: _authHeaders(),
    );
    _ensureSuccess(response);
  }

  Future<PredictionModel> createPrediction(PredictionModel model) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/predictions'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode(model.toJson()),
    );
    return _readSingle(response, PredictionModel.fromJson);
  }

  Future<RecommendationModel> createRecommendation(RecommendationModel model) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/recommendations'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode(model.toJson()),
    );
    return _readSingle(response, RecommendationModel.fromJson);
  }

  Future<List<BudgetModel>> getBudgetByUserIdAndMonthAndYear(int userId, int month, int year) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/budgets/user/$userId/date').replace(queryParameters: {
        'month': month.toString(),
        'year': year.toString()
      }),
      headers: _authHeaders(),
    );
    return _readList(response, BudgetModel.fromJson);
  }

  Future<List<TransactionModel>> getTransactionsByUserIdAndMonthAndYear(int userId, int month, int year) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/transactions/user/$userId/date').replace(queryParameters: {
        'month': month.toString(),
        'year': year.toString()
      }),
      headers: _authHeaders(),
    );
    return _readList(response, TransactionModel.fromJson);
  }

  Future<TransactionModel> updateTransaction(int transactionId, int categoryId, double amount, String description) async {
    
    final response = await client.put(
      Uri.parse('$baseUrl/api/v1/transactions/$transactionId'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode({
        'categoryId': categoryId,
        'amount': amount,
        'description': description,
      }),
    );
    return _readSingle(response, TransactionModel.fromJson);
  }

  List<T> _readList<T>(http.Response response, T Function(Map<String, dynamic>) parser) {
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded.map((item) => parser(item as Map<String, dynamic>)).toList();
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        return data.map((item) => parser(item as Map<String, dynamic>)).toList();
      }
    }

    return <T>[];
  }

  T _readSingle<T>(http.Response response, T Function(Map<String, dynamic>) parser) {
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('data') && decoded['data'] is Map<String, dynamic>) {
        return parser(decoded['data'] as Map<String, dynamic>);
      }
      return parser(decoded);
    }

    throw Exception('Invalid response format');
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed: ${response.statusCode} ${response.body}');
    }
  }

  Map<String, String> _authHeaders() {
    final token = getAuthToken();
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _jsonAuthHeaders() {
    final token = getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}