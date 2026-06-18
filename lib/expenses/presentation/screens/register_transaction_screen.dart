import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mobile_app_frontend/expenses/domain/entities/account.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/recurring_transaction.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/transaction.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/shared/presentation/widgets/common_widgets.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/classifier/ml_service.dart';

class RegisterTransactionScreen extends StatefulWidget {
  final String type;

  const RegisterTransactionScreen({Key? key, required this.type})
    : super(key: key);

  @override
  State<RegisterTransactionScreen> createState() =>
      _RegisterTransactionScreenState();
}

class _RegisterTransactionScreenState extends State<RegisterTransactionScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  Timer? _debounce;

  User? _currentUser;
  List<Account> _accounts = [];
  List<Category> _categories = [];

  int? _selectedAccountId;
  int? _selectedCategoryId;
  DateTime selectedDate = DateTime.now();

  bool _loading = true;
  bool _saving = false;

  // NUEVAS VARIABLES PARA TRANSACCIONES RECURRENTES
  bool _isRecurring = false;
  String _selectedFrequency = 'monthly'; // Valor por defecto
  final List<String> _frequencies = ['daily', 'weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (!mlService.isInitialized) {
      mlService.loadModels().then((_) => setState(() {}));
    }
    descriptionController.addListener(_onDescriptionChanged);
    amountController.addListener(() => setState(() {}));
  }

  Future<void> _loadData() async {
    try {
      final user = await AuthDI.userRepository.getCurrentUser();
      if (!mounted) return;

      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      final accounts = await ExpensesDI.accountService.getAccountsByUserId(
        user.id,
      );
      final categories = await ExpensesDI.categoryService.getCategories();

      if (!mounted) return;

      setState(() {
        _currentUser = user;
        _accounts = accounts;
        _categories = categories;
        _selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
        _selectedCategoryId = categories.isNotEmpty
            ? categories.first.id
            : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando datos: $e')));
    }
  }

  void _onDescriptionChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      final text = descriptionController.text.trim();
      if (text.length < 3) return;
      if (!mlService.isInitialized) return;
      try {
        final predictedId = await mlService.classifyCategory(text);
        if (_categories.any((c) => c.id == predictedId)) {
          if (!mounted) return;
          setState(() => _selectedCategoryId = predictedId);
        }
      } catch (_) {
        /* ignorar errores de ML */
      }
    });
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una cantidad válida')),
      );
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hay sesión activa')));
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una cuenta')));
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una categoría')));
      return;
    }

    setState(() => _saving = true);

    try {
      final typeString = widget.type == 'income' ? 'income' : 'expense';
      final cleanDescription = descriptionController.text.trim().isEmpty
          ? 'Transacción sin descripción'
          : descriptionController.text.trim();

      if (_isRecurring) {
        final recurringTransaction = RecurringTransaction(
          id: null,
          userId: _currentUser!.id,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          type: typeString,
          amount: amount,
          description: cleanDescription,
          frequency: _selectedFrequency.toUpperCase(),
          nextExecutionDate: selectedDate,
        );

        await ExpensesDI.recurringTransactionService.createRecurringTransaction(
          recurringTransaction,
        );
      } else {
        final transaction = Transaction(
          id: null,
          userId: _currentUser!.id,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          type: typeString,
          amount: amount,
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          transactionDate: selectedDate,
        );

        await ExpensesDI.transactionService.createTransaction(transaction);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isRecurring
                ? 'Transacción recurrente programada'
                : 'Transacción creada correctamente',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text(
          'Nueva ${widget.type == 'income' ? 'entrada' : 'transacción'}',
        ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monto de la ${widget.type == 'income' ? 'entrada' : 'transacción'}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: widget.type == 'income'
                          ? AppTheme.primaryGreen
                          : AppTheme.primaryRed,
                    ),
                    decoration: InputDecoration(
                      prefixText: 'S/ ',
                      prefixStyle: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: widget.type == 'income'
                            ? AppTheme.primaryGreen
                            : AppTheme.primaryRed,
                      ),
                      hintText: '0.00',
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.3)),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cuenta',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedAccountId,
                    onChanged: (v) => setState(() => _selectedAccountId = v),
                    items: _accounts
                        .map(
                          (account) => DropdownMenuItem<int>(
                            value: account.id,
                            child: Text(account.name),
                          ),
                        )
                        .toList(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Categoría',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    key: ValueKey(_selectedCategoryId),
                    value: _selectedCategoryId,
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Descripción',
                    controller: descriptionController,
                  ),
                  const SizedBox(height: 16),

                  // COMPONENTE NUEVO: CONFIGURACIÓN DE RECURRENCIA
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text(
                            '¿Es una transacción recurrente?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: const Text(
                            'Se ejecutará automáticamente según la frecuencia',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          value: _isRecurring,
                          activeColor: AppTheme.accentBlue,
                          onChanged: (bool value) {
                            setState(() {
                              _isRecurring = value;
                            });
                          },
                        ),
                        if (_isRecurring) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(color: Colors.grey),
                                const SizedBox(height: 8),
                                const Text(
                                  'Frecuencia',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedFrequency,
                                  onChanged: (v) =>
                                      setState(() => _selectedFrequency = v!),
                                  items: _frequencies
                                      .map(
                                        (f) => DropdownMenuItem<String>(
                                          value: f,
                                          child: Text(
                                            f == 'daily'
                                                ? 'Diario'
                                                : f == 'weekly'
                                                ? 'Semanal'
                                                : f == 'monthly'
                                                ? 'Mensual'
                                                : 'Anual',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppTheme.darkBg,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    _isRecurring ? 'Próxima fecha de ejecución' : 'Fecha',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: _isRecurring
                            ? DateTime.now()
                            : DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentBlue),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: TextStyle(color: AppTheme.textPrimary),
                          ),
                          const Icon(Icons.calendar_month, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveTransaction,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    descriptionController.removeListener(_onDescriptionChanged);
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
