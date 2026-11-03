import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/account.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/transaction.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late Future<List<Transaction>> _transactionsFuture;
  User? _currentUser;
  List<Account> _accounts = [];
  List<Category> _categories = [];
  bool _redirectedToLogin = false;

  // Modificado: Se inicializan como nulos para empezar el Dropdown en "Vacío"
  int? _selectedMonth;
  late int _selectedYear;

  final List<String> _monthsNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year; // El año por defecto se queda fijo
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await AuthDI.userRepository.getCurrentUser();
    if (!mounted) return;

    if (user == null) {
      if (!_redirectedToLogin) {
        _redirectedToLogin = true;
        context.go('/login');
      }
      return;
    }

    setState(() {
      _currentUser = user;
      // Lógica de carga condicional inicial:
      if (_selectedMonth == null) {
        // Cargar todo el historial general sin filtros
        _transactionsFuture = ExpensesDI.transactionService
            .getTransactionsByUserId(user.id);
      } else {
        // Cargar filtrado por el periodo seleccionado
        _transactionsFuture = ExpensesDI.transactionService
            .getTransactionsByUserIdAndMonthAndYear(
              user.id,
              _selectedMonth!,
              _selectedYear,
            );
      }
    });

    try {
      final accounts = await ExpensesDI.accountService.getAccountsByUserId(
        user.id,
      );
      final categories = await ExpensesDI.categoryService.getCategories();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _categories = categories;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudieron cargar cuentas y categorías: $error'),
          ),
        );
      }
    }
  }

  Future<void> _reload() async {
    final user = _currentUser;
    if (user == null) {
      await _loadSession();
      return;
    }

    setState(() {
      if (_selectedMonth == null) {
        _transactionsFuture = ExpensesDI.transactionService
            .getTransactionsByUserId(user.id);
      } else {
        _transactionsFuture = ExpensesDI.transactionService
            .getTransactionsByUserIdAndMonthAndYear(
              user.id,
              _selectedMonth!,
              _selectedYear,
            );
      }
    });
  }

  void _onPeriodChanged(int? newMonth) {
    if (_currentUser == null) return;
    setState(() {
      _selectedMonth = newMonth;
      if (newMonth == null) {
        _transactionsFuture = ExpensesDI.transactionService
            .getTransactionsByUserId(_currentUser!.id);
      } else {
        _transactionsFuture = ExpensesDI.transactionService
            .getTransactionsByUserIdAndMonthAndYear(
              _currentUser!.id,
              newMonth,
              _selectedYear,
            );
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _accountName(int accountId) {
    for (final account in _accounts) {
      if (account.id == accountId) return account.name;
    }
    return 'Desconocida';
  }

  String _categoryName(int categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) return category.name;
    }
    return 'Desconocida';
  }

  Future<void> _editTransaction(Transaction transaction) async {
    if (transaction.id == null) return;

    final amountController = TextEditingController(
      text: transaction.amount.toString(),
    );
    final descriptionController = TextEditingController(
      text: transaction.description ?? '',
    );
    int? selectedCategoryId = transaction.categoryId;

    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: const Text('Editar transacción'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixText: 'S/ ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value:
                      _categories.any(
                        (category) => category.id == selectedCategoryId,
                      )
                      ? selectedCategoryId
                      : null,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: _categories
                      .where((category) => category.id != null)
                      .map(
                        (category) => DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategoryId = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(
                  amountController.text.trim().replaceAll(',', '.'),
                );
                if (amount == null ||
                    amount <= 0 ||
                    selectedCategoryId == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Ingresa un monto y una categoría válidos'),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, {
                  'categoryId': selectedCategoryId,
                  'amount': amount,
                  'description': descriptionController.text.trim(),
                });
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    amountController.dispose();
    descriptionController.dispose();

    if (values == null || !mounted) return;

    try {
      await ExpensesDI.transactionService.updateTransaction(
        transaction.id!,
        values['categoryId'] as int,
        values['amount'] as double,
        values['description'] as String,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transacción actualizada correctamente')),
      );
      await _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la transacción: $error')),
      );
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    if (transaction.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Eliminar transacción'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta transacción? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ExpensesDI.transactionService.deleteTransaction(transaction.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transacción eliminada correctamente')),
      );
      await _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la transacción: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text('Historial'),
        elevation: 0,
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          // FILTRO DROPDOWN: Se inicializa vacío con invitación de selección
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.filter_list,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Filtrar por mes:',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedMonth,
                      hint: const Text(
                        'Selecciona un mes',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      dropdownColor: AppTheme.cardBg,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.primaryGreen,
                      ),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      items: [
                        // Opción para resetear el dropdown y volver a ver todas
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Ver todas'),
                        ),
                        ...List.generate(12, (index) {
                          return DropdownMenuItem<int?>(
                            value: index + 1,
                            child: Text(
                              '${_monthsNames[index]} $_selectedYear',
                            ),
                          );
                        }),
                      ],
                      onChanged: _onPeriodChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenedor principal del listado asíncrono
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error al cargar el historial:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                  );
                }

                final transactions = snapshot.data ?? [];

                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay transacciones registradas',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }

                // ORDENAMIENTO: Ordenar de mayor a menor según el monto (amount) antes de renderizar
                transactions.sort(
                  (a, b) => b.transactionDate.compareTo(a.transactionDate),
                );

                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final isIncome =
                          transaction.type.toLowerCase() == 'income';

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.darkBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: isIncome
                                    ? AppTheme.primaryGreen
                                    : AppTheme.primaryRed,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.description?.isNotEmpty == true
                                        ? transaction.description!
                                        : 'Sin descripción',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(transaction.transactionDate),
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_accountName(transaction.accountId)} | '
                                    '${_categoryName(transaction.categoryId)}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isIncome ? '+' : '-'} S/ ${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isIncome
                                    ? AppTheme.primaryGreen
                                    : AppTheme.primaryRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppTheme.textSecondary,
                              ),
                              onSelected: (action) {
                                if (action == 'edit') {
                                  _editTransaction(transaction);
                                } else {
                                  _deleteTransaction(transaction);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Eliminar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
