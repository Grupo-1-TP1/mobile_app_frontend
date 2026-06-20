import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/dashboard/presentation/screens/manual_budget_screen.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/budget.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/recommendation.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/recommendation_detail.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/transaction.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/budget_recommendation/budget_recommendation_service.dart';

class CreateBudgetScreen extends StatefulWidget {
  const CreateBudgetScreen({Key? key}) : super(key: key);

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  bool _loading = true;
  User? _user;
  List<Category> _categories = [];
  List<Transaction> _transactions = [];
  bool _mlLoading = false;
  bool _saving = false;

  Map<int, double> _suggestedBudgets = {};
  Map<int, double> _assignedBudgetsAmount = {};

  final Map<int, String> _categoryEmojis = {
    1: "🍔",
    2: "🚌",
    3: "🎓",
    4: "🎮",
    5: "💡",
    6: "💰",
    7: "🏠",
    8: "❓",
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthDI.userRepository.getCurrentUser();
    if (!mounted) return;
    if (user == null) {
      context.go('/login');
      return;
    }

    try {
      final txs = await ExpensesDI.transactionService.getTransactionsByUserId(
        user.id,
      );
      final cats = await ExpensesDI.categoryService.getCategories();
      final budgets = await ExpensesDI.budgetService.getBudgetsByUserId(
        user.id,
      );

      if (!mounted) return;
      setState(() {
        _user = user;
        _categories = cats;
        _transactions = txs;

        _assignedBudgetsAmount = {
          for (final b in budgets) b.categoryId: b.amount,
        };

        _loading = false;
      });
      await _loadMLRecommendations();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando datos de Azure: $e')),
      );
    }
  }

  Future<void> _loadMLRecommendations() async {
    if (_user == null || _categories.isEmpty) return;
    setState(() => _mlLoading = true);

    try {
      if (!budgetRecommendationService.isInitialized) {
        await budgetRecommendationService.loadModel();
      }

      final Map<int, double> suggestions = {};

      final bool isColdStart = _transactions
          .where((tx) => tx.type.toLowerCase() == 'expense')
          .isEmpty;

      if (isColdStart) {
        final userAccounts = await ExpensesDI.accountService
            .getAccountsByUserId(_user!.id);

        double totalBalance = 0.0;
        for (final account in userAccounts) {
          totalBalance += account.balance;
        }

        if (totalBalance <= 0) totalBalance = 800.0;

        final Map<int, double> universityPercentages = {
          1: 0.30, // 🍔 Alimentación (30%)
          2: 0.15, // 🚌 Transporte (15%)
          3: 0.20, // 🎓 Estudios (20%)
          4: 0.10, // 🎮 Entretenimiento (10%)
          5: 0.08, // 💡 Servicios (8%)
          6: 0.10, // 💰 Ahorro (10%)
          7: 0.02, // 🏠 Vivienda (2%)
          8: 0.05, // ❓ Otros (5%)
        };

        for (final category in _categories) {
          final id = category.id ?? -1;
          final weight = universityPercentages[id] ?? 0.05;
          suggestions[id] = double.parse(
            (totalBalance * weight).toStringAsFixed(0),
          );
        }

        double currentTotalSuggested = suggestions.values.fold(
          0,
          (sum, item) => sum + item,
        );
        double difference = totalBalance - currentTotalSuggested;

        if (difference != 0 && _categories.isNotEmpty) {
          final firstCatId = _categories.first.id ?? -1;
          suggestions[firstCatId] = (suggestions[firstCatId] ?? 0) + difference;
        }
      } else {
        final Map<int, double> spentByCategory = {};
        final Map<int, int> countByCategory = {};

        for (final tx in _transactions) {
          if (tx.type.toLowerCase() != 'expense') continue;
          spentByCategory[tx.categoryId] =
              (spentByCategory[tx.categoryId] ?? 0) + tx.amount;
          countByCategory[tx.categoryId] =
              (countByCategory[tx.categoryId] ?? 0) + 1;
        }

        for (final category in _categories) {
          final id = category.id;
          if (id == null) continue;

          final totalSpent = spentByCategory[id] ?? 0.0;
          final txCount = countByCategory[id] ?? 0;
          final avgSpent = txCount > 0 ? totalSpent / txCount : 0.0;

          final predicted = await budgetRecommendationService.recommendBudget(
            categoryId: id,
            totalSpent: totalSpent,
            transactionCount: txCount,
            averageSpent: avgSpent,
          );
          suggestions[id] = double.parse(predicted.toStringAsFixed(0));
        }
      }

      if (!mounted) return;
      setState(() {
        _suggestedBudgets = suggestions;
      });
    } catch (e) {
      print("Error al procesar recomendaciones de presupuesto: $e");
    } finally {
      if (mounted) setState(() => _mlLoading = false);
    }
  }

  Future<void> _applyAndSaveMLSuggestions() async {
    if (_user == null || _suggestedBudgets.isEmpty) return;
    setState(() => _saving = true);

    final now = DateTime.now();

    try {
      final List<RecommendationDetail> recommendationDetails = [];
      final List<Future> saveFutures = [];

      _suggestedBudgets.forEach((catId, recommendedAmount) {
        if (recommendedAmount <= 0) return;

        final actualLimit = _assignedBudgetsAmount[catId] ?? 0.0;

        // 1. Añadimos el sub-detalle para la auditoría de cambio financiero de la IA
        recommendationDetails.add(
          RecommendationDetail(
            categoryId: catId,
            currentLimit: actualLimit,
            suggestedLimit: recommendedAmount,
          ),
        );

        // 2. Preparamos el save futuro de cada presupuesto individual
        final newBudget = Budget(
          id: null,
          userId: _user!.id,
          categoryId: catId,
          amount: recommendedAmount,
          spent: 0.0,
          date: now,
        );
        saveFutures.add(ExpensesDI.budgetService.createBudget(newBudget));
      });

      // 3. Empaquetamos la raíz de la recomendación con los detalles mapeados
      final projectedSavings = _calculateProjectedSavings();
      final fullRecommendation = Recommendation(
        id: null,
        userId: _user!.id,
        projectedSavings: projectedSavings,
        details: recommendationDetails,
      );

      // 4. Mandamos todo a Azure concurrentemente mediante Future.wait
      await Future.wait([
        ...saveFutures,
        ExpensesDI.recommendationService.createRecommendation(
          fullRecommendation,
        ),
      ]);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Presupuestos y optimizaciones de la IA aplicados con éxito',
          ),
        ),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar sugerencias: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  double _calculateProjectedSavings() {
    double totalDiff = 0.0;
    _suggestedBudgets.forEach((id, suggested) {
      final actual = _assignedBudgetsAmount[id] ?? suggested;
      totalDiff += (actual - suggested);
    });
    return totalDiff;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _mlLoading) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    final projectedSavings = _calculateProjectedSavings();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        title: const Text(
          'Creación de presupuesto',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categoría',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Actual   ',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'ML sugiere   ',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Cambio',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final c = _categories[i];
                  final catId = c.id ?? -1;
                  final emoji = _categoryEmojis[catId] ?? "💰";

                  final actual = _assignedBudgetsAmount[catId] ?? 0.0;
                  final suggested = _suggestedBudgets[catId] ?? 0.0;
                  final diff = suggested - actual;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$emoji   ${c.name}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'S/ ${actual.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Text(
                                  'S/ ${suggested.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.purpleAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: diff >= 0
                                        ? AppTheme.primaryGreen.withOpacity(0.1)
                                        : AppTheme.primaryRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    diff >= 0
                                        ? '+S/${diff.toStringAsFixed(0)}'
                                        : '-S/${diff.abs().toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: diff >= 0
                                          ? AppTheme.primaryGreen
                                          : AppTheme.primaryRed,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: actual > 0
                                  ? (actual /
                                            (actual > suggested
                                                ? actual
                                                : suggested))
                                        .clamp(0.0, 1.0)
                                  : 0.1,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade700,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: suggested > 0
                                  ? (suggested /
                                            (actual > suggested
                                                ? actual
                                                : suggested))
                                        .clamp(0.0, 1.0)
                                  : 0.1,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.purpleAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2335),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Con este ajuste, proyectamos +S/ ${projectedSavings.abs().toStringAsFixed(0)}/mes adicional de ahorro',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: true,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _applyAndSaveMLSuggestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Aplicar sugerencia',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => ManualBudgetScreen(
                              user: _user!,
                              categories: _categories,
                              initialSuggestions: _suggestedBudgets,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadData();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Personalizar',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
