import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/budget.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';

class CreateBudgetScreen extends StatefulWidget {
  const CreateBudgetScreen({Key? key}) : super(key: key);

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  User? _user;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      final cats = await ExpensesDI.categoryService.getCategories();
      if (!mounted) return;
      setState(() {
        _user = user;
        _categories = cats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando categorías: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildMLSuggestionTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sugerencia inteligente', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'Basado en 3 meses de datos (ML no implementado aún). Aquí verás la propuesta del modelo.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final c = _categories[i];
                // Placeholder suggestion numbers
                final suggested = 100.0 + (i * 50);
                final current = 80.0 + (i * 20);
                final diff = suggested - current;
                final accent = AppTheme.primaryGreen;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(8))),
                                FractionallySizedBox(
                                  widthFactor: (current / (suggested > 0 ? suggested : 1)).clamp(0.0, 1.0),
                                  child: Container(height: 8, decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(8))),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  child: FractionallySizedBox(
                                    widthFactor: (suggested / (suggested > 0 ? suggested : 1)).clamp(0.0, 1.0),
                                    child: Container(height: 8, decoration: BoxDecoration(color: Colors.purple.withOpacity(0.4), borderRadius: BorderRadius.circular(8))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(999)),
                            child: Text('S/ ${suggested.toStringAsFixed(0)}', style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Actual: S/ ${current.toStringAsFixed(0)}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          Text(diff >= 0 ? '+S/ ${diff.toStringAsFixed(0)}' : 'S/ ${diff.toStringAsFixed(0)}', style: TextStyle(color: diff >= 0 ? AppTheme.primaryGreen : AppTheme.primaryRed, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ML no implementado todavía')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Aplicar sugerencia'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _tabController.animateTo(1),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Personalizar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualTab() {
    return ManualBudgetScreen(
      user: _user!,
      categories: _categories,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text('Presupuesto manual', style: TextStyle(color: AppTheme.textPrimary)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'IA · ML'),
            Tab(text: 'Manual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMLSuggestionTab(),
          _buildManualTab(),
        ],
      ),
    );
  }
}

class ManualBudgetScreen extends StatefulWidget {
  final User user;
  final List<Category> categories;

  const ManualBudgetScreen({
    Key? key,
    required this.user,
    required this.categories,
  }) : super(key: key);

  @override
  State<ManualBudgetScreen> createState() => _ManualBudgetScreenState();
}

class _ManualBudgetScreenState extends State<ManualBudgetScreen> {
  final Map<int, TextEditingController> _controllers = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final c in widget.categories) {
      if (c.id != null) _controllers[c.id!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final ctl in _controllers.values) ctl.dispose();
    super.dispose();
  }

  DateTime _startOfMonth(DateTime now) => DateTime(now.year, now.month, 1);
  DateTime _endOfMonth(DateTime now) => DateTime(now.year, now.month + 1, 0);

  Future<void> _saveBudgets() async {
    final entries = <Budget>[];
    final now = DateTime.now();
    final start = _startOfMonth(now);
    final end = _endOfMonth(now);

    for (final c in widget.categories) {
      final id = c.id;
      if (id == null) continue;
      final text = _controllers[id]?.text.trim() ?? '';
      if (text.isEmpty) continue;
      final amount = double.tryParse(text.replaceAll(',', '.'));
      if (amount == null || amount <= 0) continue;

      entries.add(Budget(
        id: null,
        userId: widget.user.id,
        categoryId: id,
        amount: amount,
        spent: 0.0,
        startDate: start,
        endDate: end,
      ));
    }

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa al menos un monto para guardar')));
      return;
    }

    setState(() => _saving = true);

    try {
      final futures = entries.map((b) => ExpensesDI.budgetService.createBudget(b));
      await Future.wait(futures);
      if (!mounted) return;
      // return true so parent can reload
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: widget.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final cat = widget.categories[index];
                final controller = _controllers[cat.id!]!;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(cat.name, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.0,
                            minHeight: 6,
                            backgroundColor: Colors.white.withOpacity(0.04),
                            valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 110,
                        child: TextFormField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'S/ 0',
                            hintStyle: TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveBudgets,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar presupuesto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(false),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Buscar sugerencia'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}