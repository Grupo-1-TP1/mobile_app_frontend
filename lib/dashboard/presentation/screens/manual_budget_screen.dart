import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/budget.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';

class ManualBudgetScreen extends StatefulWidget {
  final User user;
  final List<Category> categories;
  final Map<int, double> initialSuggestions;

  const ManualBudgetScreen({
    Key? key,
    required this.user,
    required this.categories,
    required this.initialSuggestions,
  }) : super(key: key);

  @override
  State<ManualBudgetScreen> createState() => _ManualBudgetScreenState();
}

class _ManualBudgetScreenState extends State<ManualBudgetScreen> {
  final Map<int, TextEditingController> _controllers = {};
  bool _saving = false;

  final Map<int, String> _categoryEmojis = {
    1: "🍔",
    2: "🚌",
    3: "🎓",
    4: "🎮",
    5: "💡",
    6: "💰",
    7: "🏠",
    8: "❓"
  };

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    for (final c in widget.categories) {
      if (c.id != null) {
        final controller = TextEditingController();
        final suggestedAmount = widget.initialSuggestions[c.id!];
        if (suggestedAmount != null && suggestedAmount > 0) {
          controller.text = suggestedAmount.toStringAsFixed(0);
        }

        controller.addListener(() {
          if (mounted) setState(() {});
        });

        _controllers[c.id!] = controller;
      }
    }
  }

  @override
  void dispose() {
    for (final ctl in _controllers.values) ctl.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    double total = 0;
    for (final controller in _controllers.values) {
      final val = double.tryParse(controller.text.trim()) ?? 0;
      total += val;
    }
    return total;
  }

  Future<void> _saveBudgets() async {
    final entries = <Budget>[];
    final now = DateTime.now();

    for (final c in widget.categories) {
      final id = c.id;
      if (id == null) continue;
      final text = _controllers[id]?.text.trim() ?? '';
      if (text.isEmpty) continue;
      final amount = double.tryParse(text.replaceAll(',', '.'));
      if (amount == null || amount <= 0) continue;

      entries.add(
        Budget(
          id: null,
          userId: widget.user.id,
          categoryId: id,
          amount: amount,
          spent: 0.0,
          date: now
        ),
      );
    }

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa al menos un monto para guardar')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final futures = entries.map(
        (b) => ExpensesDI.budgetService.createBudget(b),
      );
      await Future.wait(futures);
      if (!mounted) return;
      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotal();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        title: const Text(
          'Presupuesto Manual',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Total presupuestado: ',
                      style: const TextStyle(color: AppTheme.textSecondary),
                      children: [
                        TextSpan(
                          text: 'S/ ${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveBudgets,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                              'Guardar presupuesto',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Buscar sugerencia',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Define cuánto quieres gastar por categoría',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: widget.categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cat = widget.categories[index];
                  final controller = _controllers[cat.id!]!;
                  final emoji = _categoryEmojis[cat.id!] ?? "💰";

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$emoji  ${cat.name}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 0.35,
                              minHeight: 6,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation(
                                AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              prefixText: 'S/ ',
                              prefixStyle: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              hintText: '0',
                              hintStyle: TextStyle(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
