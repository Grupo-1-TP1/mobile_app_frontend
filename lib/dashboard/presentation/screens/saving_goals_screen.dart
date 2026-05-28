import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/saving_goal.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({Key? key}) : super(key: key);

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  User? _currentUser;
  Future<List<SavingGoal>>? _goalsFuture;
  bool _redirectedToLogin = false;
  int? _confirmDeleteGoalId;

  @override
  void initState() {
    super.initState();
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
      _goalsFuture = ExpensesDI.savingGoalService.getSavingGoalsByUserId(
        user.id,
      );
    });
  }

  Future<void> _reload() async {
    final user = _currentUser;
    if (user == null) {
      await _loadSession();
      return;
    }

    setState(() {
      _goalsFuture = ExpensesDI.savingGoalService.getSavingGoalsByUserId(
        user.id,
      );
    });
  }

  String _formatDeadline(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _emojiForGoal(SavingGoal goal) {
    final name = goal.name.toLowerCase();

    if (name.contains('viaje')) return '✈️';
    if (name.contains('laptop') || name.contains('pc')) return '💻';
    if (name.contains('curso') || name.contains('estudio')) return '📚';
    if (name.contains('casa')) return '🏠';
    if (name.contains('auto') || name.contains('carro')) return '🚗';
    return '🎯';
  }

  Color _colorForIndex(int index) {
    switch (index % 4) {
      case 0:
        return const Color(0xFF2DD4BF);
      case 1:
        return const Color(0xFF60A5FA);
      case 2:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFFB7185);
    }
  }

  Future<void> _confirmDelete(SavingGoal goal) async {
    setState(() => _confirmDeleteGoalId = goal.id);
  }

  Future<void> _deleteGoal(SavingGoal goal) async {
    if (goal.id == null) return;

    await ExpensesDI.savingGoalService.deleteSavingGoal(goal.id!);
    if (!mounted) return;

    setState(() => _confirmDeleteGoalId = null);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null || _goalsFuture == null) {
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
        child: FutureBuilder<List<SavingGoal>>(
          future: _goalsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar las metas',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              );
            }

            final goals = snapshot.data ?? [];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Metas de ahorro',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final created = await context.push<bool>(
                            '/home/savings/create',
                          );
                          if (created == true && mounted) {
                            await _reload();
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Meta'),
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
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount:
                          goals.length + (_confirmDeleteGoalId != null ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (_confirmDeleteGoalId != null && index == 1) {
                          final goalToDelete = goals.firstWhere(
                            (goal) => goal.id == _confirmDeleteGoalId,
                          );
                          return _buildDeleteConfirmCard(goalToDelete);
                        }

                        final adjustedIndex =
                            _confirmDeleteGoalId != null && index > 1
                            ? index - 1
                            : index;

                        final goal = goals[adjustedIndex];
                        final progress = goal.progress.clamp(0.0, 1.0);
                        final accentColor = _colorForIndex(adjustedIndex);
                        final emoji = _emojiForGoal(goal);

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12213A),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: accentColor.withOpacity(0.18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.22),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.16),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      goal.name,
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.edit,
                                      color: AppTheme.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _confirmDelete(goal),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: AppTheme.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${(progress * 100).round()}%',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.08,
                                  ),
                                  valueColor: AlwaysStoppedAnimation(
                                    accentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'S/ ${goal.currentAmount.toStringAsFixed(0)} ahorrado',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Meta: S/ ${goal.targetAmount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Proyección: ${_formatDeadline(goal.deadline)}',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildDeleteConfirmCard(SavingGoal goal) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12213A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF6B6B),
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            '¿Está seguro de eliminar esta meta de ahorro?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Una vez eliminada no podrá ser recuperada',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await _deleteGoal(goal);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Eliminar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _confirmDeleteGoalId = null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
