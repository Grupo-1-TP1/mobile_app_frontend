import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/budget.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({Key? key}) : super(key: key);

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  User? _currentUser;
  Future<List<Budget>>? _budgetsFuture;
  Future<List<Category>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await AuthDI.userRepository.getCurrentUser();
    if (!mounted) return;

    if (user == null) {
      context.go('/login');
      return;
    }

    setState(() {
      _currentUser = user;
      _budgetsFuture = ExpensesDI.budgetService.getBudgetsByUserId(user.id);
      _categoriesFuture = ExpensesDI.categoryService.getCategories();
    });
  }

  Future<void> _reload() async {
    final user = _currentUser;
    if (user == null) {
      await _loadSession();
      return;
    }

    setState(() {
      _budgetsFuture = ExpensesDI.budgetService.getBudgetsByUserId(user.id);
      _categoriesFuture = ExpensesDI.categoryService.getCategories();
    });
  }

  Color _accentColorForIndex(int index) {
    switch (index % 4) {
      case 0:
        return const Color(0xFFF59E0B);
      case 1:
        return const Color(0xFF2DD4BF);
      case 2:
        return const Color(0xFF60A5FA);
      default:
        return const Color(0xFFFB7185);
    }
  }

  String _emojiForCategory(String name) {
    final value = name.toLowerCase();
    if (value.contains('comida') || value.contains('food')) return '🍔';
    if (value.contains('transporte') || value.contains('bus')) return '🚌';
    if (value.contains('ocio') || value.contains('fun')) return '🎮';
    if (value.contains('educ')) return '📚';
    if (value.contains('casa')) return '🏠';
    return '💳';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null ||
        _budgetsFuture == null ||
        _categoriesFuture == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF081427),
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF081427),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([_budgetsFuture!, _categoriesFuture!]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar presupuestos',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              );
            }

            final budgets = (snapshot.data?[0] as List<Budget>?) ?? [];
            final categories = (snapshot.data?[1] as List<Category>?) ?? [];

            final categoryById = {
              for (final category in categories)
                if (category.id != null) category.id!: category.name,
            };

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Presupuestos',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final created = await context.push<bool>(
                            '/home/budgets/create',
                          );
                          if (created == true && mounted) {
                            await _reload();
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nuevo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3B3D),
                          foregroundColor: const Color(0xFF34D399),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _reload,
                    child: budgets.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.28,
                              ),
                              Center(
                                child: Text(
                                  'No hay presupuestos todavía',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: budgets.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final budget = budgets[index];
                              final categoryName =
                                  categoryById[budget.categoryId] ??
                                  'Categoría ${budget.categoryId}';
                              final accentColor = _accentColorForIndex(index);

                              final spent = budget.spent;
                              final total = budget.amount;
                              final remaining = budget.remainingAmount;
                              final progress = total == 0
                                  ? 0.0
                                  : (spent / total).clamp(0.0, 1.0);

                              final usedPercent = total == 0
                                  ? 0
                                  : ((spent / total) * 100).round();
                              final isOverBudget = spent > total;
                              final labelPercent = isOverBudget
                                  ? '$usedPercent% 🚨'
                                  : '$usedPercent% usado';

                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF12213A),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.20),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 4,
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        14,
                                        16,
                                        14,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                _emojiForCategory(categoryName),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  categoryName,
                                                  style: TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: accentColor
                                                      .withOpacity(0.14),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                ),
                                                child: Text(
                                                  labelPercent,
                                                  style: TextStyle(
                                                    color: isOverBudget
                                                        ? const Color(
                                                            0xFFFF6B6B,
                                                          )
                                                        : accentColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 7,
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.08),
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    isOverBudget
                                                        ? const Color(
                                                            0xFFFF6B6B,
                                                          )
                                                        : accentColor,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'S/ ${spent.toStringAsFixed(0)} gastado',
                                                style: TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                isOverBudget
                                                    ? 'S/ ${remaining.abs().toStringAsFixed(0)} excedido'
                                                    : 'S/ ${remaining.toStringAsFixed(0)} restante',
                                                style: TextStyle(
                                                  color: isOverBudget
                                                      ? const Color(0xFFFF6B6B)
                                                      : accentColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
