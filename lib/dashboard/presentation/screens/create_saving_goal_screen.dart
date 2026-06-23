import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/saving_goal.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/recurring_transaction.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';

class CreateSavingGoalScreen extends StatefulWidget {
  const CreateSavingGoalScreen({Key? key}) : super(key: key);

  @override
  State<CreateSavingGoalScreen> createState() => _CreateSavingGoalScreenState();
}

class _CreateSavingGoalScreenState extends State<CreateSavingGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  final _recurringAmountController =
      TextEditingController(); // NUEVO: Cuánto aportará

  String _selectedFrequency = 'MONTHLY'; // NUEVO: Frecuencia por defecto
  DateTime? _predictedDeadline; // NUEVO: Calculada automáticamente
  bool _saving = false;
  User? _currentUser;
  bool _redirectedToLogin = false;

  final List<Map<String, String>> _frequencyOptions = const [
    {'value': 'DAILY', 'label': 'Diario'},
    {'value': 'WEEKLY', 'label': 'Semanal'},
    {'value': 'MONTHLY', 'label': 'Mensual'},
    {'value': 'YEARLY', 'label': 'Anual'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _recurringAmountController.dispose();
    super.dispose();
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
      _currentAmountController.text = '0';
    });
  }

  // --- NUEVA FUNCIÓN: PREDICCIÓN AUTOMÁTICA DE DEADLINE ---
  void _updatePredictedDeadline() {
    final target = double.tryParse(_targetAmountController.text.trim()) ?? 0;
    final current = double.tryParse(_currentAmountController.text.trim()) ?? 0;
    final recurring =
        double.tryParse(_recurringAmountController.text.trim()) ?? 0;

    if (target <= 0 || recurring <= 0 || current >= target) {
      setState(() => _predictedDeadline = null);
      return;
    }

    final remaining = target - current;
    double daysToTarget = 0;

    // Calcular la conversión de la frecuencia a días aproximados
    switch (_selectedFrequency) {
      case 'DAILY':
        daysToTarget = remaining / recurring;
        break;
      case 'WEEKLY':
        daysToTarget = (remaining / recurring) * 7;
        break;
      case 'MONTHLY':
        daysToTarget = (remaining / recurring) * 30.44;
        break;
      case 'YEARLY':
        daysToTarget = (remaining / recurring) * 365;
        break;
    }

    setState(() {
      _predictedDeadline = DateTime.now().add(
        Duration(days: daysToTarget.round()),
      );
    });
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null || _predictedDeadline == null) return;

    final targetAmount =
        double.tryParse(_targetAmountController.text.trim()) ?? 0;
    final currentAmount =
        double.tryParse(_currentAmountController.text.trim()) ?? 0;
    final recurringAmount =
        double.tryParse(_recurringAmountController.text.trim()) ?? 0;

    setState(() => _saving = true);

    try {
      // 1. Registrar la meta de ahorro
      final goal = SavingGoal(
        id: null,
        userId: _currentUser!.id,
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: _predictedDeadline!,
      );

      // Guardamos la meta
      final createdGoal = await ExpensesDI.savingGoalService.createSavingGoal(
        goal,
      );
      final generatedGoalId = createdGoal.id;

      // 2. Registrar la Transacción Recurrente vinculada al ID de la meta
      final recurringTransaction = RecurringTransaction(
        id: null,
        userId: _currentUser!.id,
        accountId:
            1, // AQUÍ: Usa el ID de la cuenta correspondiente del usuario
        categoryId: 1, // AQUÍ: El ID de la categoría que uses para tus ahorros
        savingGoalId: generatedGoalId,
        type:
            'EXPENSE', // Tratado como egreso de la cuenta principal hacia la meta
        amount: recurringAmount,
        description:
            'Ahorro programado automático: ${_nameController.text.trim()}',
        frequency: _selectedFrequency,
        nextExecutionDate: DateTime.now().add(
          const Duration(days: 1),
        ), // Inicia mañana o según lógica
      );

      await ExpensesDI.recurringTransactionService.createRecurringTransaction(
        recurringTransaction,
      );

      if (!mounted) return;
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo procesar la operación: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF081427),
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF081427),
      appBar: AppBar(
        backgroundColor: const Color(0xFF081427),
        elevation: 0,
        title: Text(
          'Nueva meta de ahorro',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF12213A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Nombre de la Meta
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Nombre de la meta (ej. Laptop)',
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Monto Objetivo
                    TextFormField(
                      controller: _targetAmountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Monto objetivo',
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixText: 'S/ ',
                      ),
                      onChanged: (_) => _updatePredictedDeadline(),
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Ingresa un monto válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Monto Inicial
                    TextFormField(
                      controller: _currentAmountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Monto inicial ya ahorrado',
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixText: 'S/ ',
                      ),
                      onChanged: (_) => _updatePredictedDeadline(),
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        if (amount == null || amount < 0) {
                          return 'Ingresa un monto válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white10, height: 24),

                    // NUEVO: Monto de Aporte Recurrente
                    TextFormField(
                      controller: _recurringAmountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: '¿Cuánto dinero vas a destinar?',
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixText: 'S/ ',
                      ),
                      onChanged: (_) => _updatePredictedDeadline(),
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Ingresa un monto de aporte válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // NUEVO: Selector de Frecuencia de Ahorro
                    DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      dropdownColor: const Color(0xFF12213A),
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Frecuencia de aporte',
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _frequencyOptions.map((freq) {
                        return DropdownMenuItem<String>(
                          value: freq['value'],
                          child: Text(freq['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedFrequency = value);
                          _updatePredictedDeadline();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // NUEVO: Tarjeta de información predictiva en tiempo real
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF12213A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _predictedDeadline != null
                        ? AppTheme.primaryGreen.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Predicción de Logro Automática',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _predictedDeadline == null
                          ? 'Ingresa los montos y frecuencia para calcular tu fecha límite.'
                          : 'Completarás tu meta estimada el:\n${_predictedDeadline!.day.toString().padLeft(2, '0')}/${_predictedDeadline!.month.toString().padLeft(2, '0')}/${_predictedDeadline!.year}',
                      style: TextStyle(
                        color: _predictedDeadline == null
                            ? AppTheme.textSecondary
                            : AppTheme.primaryGreen,
                        fontSize: 14,
                        fontWeight: _predictedDeadline != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Botón Guardar Meta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_saving || _predictedDeadline == null)
                      ? null
                      : _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                          'Guardar meta',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
