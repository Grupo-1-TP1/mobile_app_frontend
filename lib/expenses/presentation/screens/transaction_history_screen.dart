import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                                    'Cuenta ${transaction.accountId} | Categoría ${transaction.categoryId}',
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
