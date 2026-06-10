import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/account.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/budget.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/transaction.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  List<Account> _accounts = [];
  List<Budget> _budgets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final transactions = await ExpensesDI.transactionService
          .getTransactionsByUserId(widget.user.id);
      final categories = await ExpensesDI.categoryService.getCategories();
      final accounts = await ExpensesDI.accountService.getAccountsByUserId(
        widget.user.id,
      );
      final budgets = await ExpensesDI.budgetService.getBudgetsByUserId(
        widget.user.id,
      );

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
        _categories = categories;
        _accounts = accounts;
        _budgets = budgets;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  double get _totalBalance =>
      _accounts.fold<double>(0, (sum, account) => sum + account.balance);

  List<_CategorySummary> get _categorySummaries {
    final categoryMap = {
      for (final category in _categories)
        if (category.id != null) category.id!: category.name,
    };

    return _budgets.take(3).map((budget) {
      return _CategorySummary(
        label:
            categoryMap[budget.categoryId] ?? 'Categoría ${budget.categoryId}',
        amount: 'S/ ${budget.remainingAmount.toStringAsFixed(2)}',
        color: AppTheme.primaryGreen,
      );
    }).toList();
  }

  List<_BudgetItem> get _budgetItems {
    final categoryMap = {
      for (final category in _categories)
        if (category.id != null) category.id!: category.name,
    };

    return _budgets.take(3).map((budget) {
      final categoryName =
          categoryMap[budget.categoryId] ?? 'Categoría ${budget.categoryId}';
      final progress = budget.progress.clamp(0.0, 1.0);
      final isWarning = progress >= 0.8;
      final isExceeded = progress >= 1.0;

      return _BudgetItem(
        title: categoryName,
        spentLabel:
            'Gastado: S/ ${budget.spent.toStringAsFixed(2)} de S/ ${budget.amount.toStringAsFixed(2)}',
        remainingLabel:
            'Disponible: S/ ${budget.remainingAmount.toStringAsFixed(2)}',
        percentLabel: '${(progress * 100).toStringAsFixed(0)}%',
        progress: progress,
        color: isExceeded
            ? AppTheme.primaryRed
            : isWarning
                ? Colors.orange
                : AppTheme.primaryGreen,
        exceeded: isExceeded,
      );
    }).toList();
  }

  List<_CategorySummary> get _topCategories {
    final expenseTotals = <int, double>{};

    for (final transaction in _transactions) {
      if (transaction.type.toLowerCase() == 'expense') {
        expenseTotals.update(
          transaction.categoryId,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    final categoryMap = {
      for (final category in _categories)
        if (category.id != null) category.id!: category.name,
    };

    final entries = expenseTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.take(3).map((entry) {
      return _CategorySummary(
        label: categoryMap[entry.key] ?? 'Categoría ${entry.key}',
        amount: 'S/ ${entry.value.toStringAsFixed(2)}',
        color: _summaryColorForIndex(_topCategoriesIndex(entry.key)),
      );
    }).toList();
  }

  int _topCategoriesIndex(int categoryId) {
    final expenseTotals = <int, double>{};

    for (final transaction in _transactions) {
      if (transaction.type.toLowerCase() == 'expense') {
        expenseTotals.update(
          transaction.categoryId,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    final sorted = expenseTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final index = sorted.indexWhere((e) => e.key == categoryId);
    return index < 0 ? 0 : index;
  }

  Color _summaryColorForIndex(int index) {
    switch (index) {
      case 0:
        return AppTheme.primaryGreen;
      case 1:
        return AppTheme.primaryRed;
      default:
        return AppTheme.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text(
          widget.user.username,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppTheme.primaryGreen,
            ),
            onPressed: () => context.go('/home/chatbot'),
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: AppTheme.primaryGreen),
            onPressed: () => context.go('/home/alerts'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'S/ ${_totalBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _loading
                        ? [
                            _InfoItem('Cargando', '...', AppTheme.primaryGreen),
                            _InfoItem('Cargando', '...', AppTheme.primaryRed),
                            _InfoItem('Cargando', '...', AppTheme.accentBlue),
                          ]
                        : _categorySummaries.isEmpty
                            ? [
                                _InfoItem(
                                  'Sin datos',
                                  'S/ 0.00',
                                  AppTheme.primaryGreen,
                                ),
                                _InfoItem(
                                  'Sin datos',
                                  'S/ 0.00',
                                  AppTheme.primaryRed,
                                ),
                                _InfoItem(
                                  'Sin datos',
                                  'S/ 0.00',
                                  AppTheme.accentBlue,
                                ),
                              ]
                            : _categorySummaries
                                .map(
                                  (item) => _InfoItem(
                                    item.label,
                                    item.amount,
                                    item.color,
                                  ),
                                )
                                .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  Icons.add_circle,
                  'Registrar\nIngreso',
                  Colors.green,
                  onTap: () => context.push('/home/transaction/income'),
                ),
                _ActionButton(
                  Icons.remove_circle,
                  'Registrar\nGasto',
                  Colors.red,
                  onTap: () => context.push('/home/transaction/expense'),
                ),
                _ActionButton(
                  Icons.history,
                  'Historial',
                  Colors.blue,
                  onTap: () => context.push('/home/history'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Presupuestos',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/home/budgets'),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: CircularProgressIndicator(),
              )
            else if (_budgets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'No hay presupuestos creados',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              ..._budgetItems.map(
                (budget) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: budget.exceeded ? AppTheme.primaryRed : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF13283B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                color: budget.color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budget.title,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    budget.spentLabel,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              budget.percentLabel,
                              style: TextStyle(
                                color: budget.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: budget.progress,
                            minHeight: 8,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              budget.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          budget.remainingLabel,
                          style: TextStyle(
                            color: budget.exceeded
                                ? AppTheme.primaryRed
                                : AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Últimas transacciones',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              )
            else if (_transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No hay transacciones',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              ..._generateTransactions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _generateTransactions() {
    final recent = _transactions.take(5).toList();

    return recent.map((t) {
      final isIncome = t.type.toLowerCase() == 'income';
      final dateLabel = _formatRelativeDate(t.transactionDate);
      final categoryName = _categories
          .firstWhere(
            (c) => c.id == t.categoryId,
            orElse: () => Category(
              id: null,
              name: 'Categoría ${t.categoryId}',
              description: null,
            ),
          )
          .name;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? AppTheme.primaryGreen : AppTheme.primaryRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.description?.isNotEmpty == true
                        ? t.description!
                        : categoryName,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'} S/ ${t.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? AppTheme.primaryGreen : AppTheme.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff <= 0) return 'Hoy';
    if (diff == 1) return 'Hace 1 día';
    return 'Hace $diff días';
  }
}

class _CategorySummary {
  final String label;
  final String amount;
  final Color color;

  const _CategorySummary({
    required this.label,
    required this.amount,
    required this.color,
  });
}

class _BudgetItem {
  final String title;
  final String spentLabel;
  final String remainingLabel;
  final String percentLabel;
  final double progress;
  final Color color;
  final bool exceeded;

  const _BudgetItem({
    required this.title,
    required this.spentLabel,
    required this.remainingLabel,
    required this.percentLabel,
    required this.progress,
    required this.color,
    required this.exceeded,
  });
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _InfoItem(this.label, this.amount, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(this.icon, this.label, this.color, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}