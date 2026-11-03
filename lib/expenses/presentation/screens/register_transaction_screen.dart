import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mobile_app_frontend/expenses/domain/entities/account.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/prediction.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/recurring_transaction.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/transaction.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/classifier/expense_classifier_service_io.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/shared/presentation/widgets/common_widgets.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';

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
  String _selectedFrequency = 'MONTHLY'; // Valor por defecto
  final List<String> _frequencies = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];

  double _currentConfidenceScore = 1.0;

  String _frequencyLabel(String frequency) {
    switch (frequency) {
      case 'DAILY':
        return 'Diario';
      case 'WEEKLY':
        return 'Semanal';
      case 'YEARLY':
        return 'Anual';
      default:
        return 'Mensual';
    }
  }

  Future<void> _configureRecurringTransaction() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    DateTime dialogDate = _isRecurring
        ? selectedDate
        : DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    String dialogFrequency = _selectedFrequency;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Configurar recurrencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: dialogFrequency,
                decoration: const InputDecoration(labelText: 'Frecuencia'),
                items: _frequencies
                    .map(
                      (frequency) => DropdownMenuItem<String>(
                        value: frequency,
                        child: Text(_frequencyLabel(frequency)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => dialogFrequency = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Próxima fecha de ejecución'),
                subtitle: Text(
                  '${dialogDate.day}/${dialogDate.month}/${dialogDate.year}',
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: dialogDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setDialogState(() => dialogDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, {
                'frequency': dialogFrequency,
                'date': dialogDate,
              }),
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    setState(() {
      if (result == null) {
        _isRecurring = false;
        return;
      }
      _isRecurring = true;
      _selectedFrequency = result['frequency'] as String;
      selectedDate = result['date'] as DateTime;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    if (!expenseClassifierService.isInitialized) {
      expenseClassifierService.loadModel().then((_) => setState(() {}));
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
        _selectedCategoryId = null;
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
    if (_selectedCategoryId != null && mounted) {
      setState(() => _selectedCategoryId = null);
    }
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      final text = descriptionController.text.trim();
      if (text.length < 3 || !expenseClassifierService.isInitialized) {
        if (mounted) {
          setState(() => _selectedCategoryId = null);
        }
        return;
      }

      try {
        final ClassificationResult result = await expenseClassifierService
            .classifyExpense(text);

        if (!mounted) return;
        setState(() {
          _selectedCategoryId =
              _categories.any((category) => category.id == result.categoryId)
              ? result.categoryId
              : null;
          _currentConfidenceScore = result.confidence;
        });
      } catch (e) {
        print("Error en carga: $e");
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

    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa una descripción para categorizar la transacción',
          ),
        ),
      );
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una cuenta')));
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Espera a que la descripción sea categorizada automáticamente',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final typeString = widget.type == 'income' ? 'income' : 'expense';
      final recurringType = typeString.toUpperCase();
      final cleanDescription = descriptionController.text.trim().isEmpty
          ? 'Transacción sin descripción'
          : descriptionController.text.trim();

      if (_isRecurring) {
        final recurringTransaction = RecurringTransaction(
          id: null,
          userId: _currentUser!.id,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          type: recurringType,
          amount: amount,
          description: cleanDescription,
          frequency: _selectedFrequency,
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

        final createdTransaction = await ExpensesDI.transactionService
            .createTransaction(transaction);

        double finalScore = _currentConfidenceScore;
        if (transaction.categoryId != _selectedCategoryId) {
          finalScore = 0.0;
        }

        final predictionPayload = Prediction(
          id: null,
          confidenceScore: finalScore,
          categoryId: createdTransaction.categoryId,
          text: createdTransaction.description ?? 'Sin descripción',
          transactionId: createdTransaction.id!,
        );

        await ExpensesDI.predictionService.createPrediction(predictionPayload);
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isRecurring
                ? 'Transacción recurrente programada'
                : 'Transacción creada correctamente',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Error al guardar'),
          content: SingleChildScrollView(child: SelectableText(e.toString())),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
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
                    value: null,
                    hint: const Text(
                      'Selecciona una cuenta',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
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
                  CustomTextField(
                    label: 'Descripción',
                    controller: descriptionController,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedCategoryId != null)
                    Text(
                      'Categoría detectada: ${_categories.firstWhere((category) => category.id == _selectedCategoryId).name}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    )
                  else
                    const Text(
                      'Escribe una descripción para categorizar automáticamente',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  const SizedBox(height: 16),

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
                          onChanged: (bool value) async {
                            if (value) {
                              await _configureRecurringTransaction();
                            } else if (mounted) {
                              setState(() => _isRecurring = false);
                            }
                          },
                        ),
                        if (_isRecurring)
                          ListTile(
                            title: Text(
                              '${_frequencyLabel(_selectedFrequency)} · '
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            ),
                            subtitle: const Text(
                              'Toca para editar la recurrencia',
                            ),
                            trailing: const Icon(Icons.edit_calendar),
                            onTap: _configureRecurringTransaction,
                          ),
                      ],
                    ),
                  ),

                  if (!_isRecurring) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Fecha',
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
                          firstDate: DateTime(2020),
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
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
