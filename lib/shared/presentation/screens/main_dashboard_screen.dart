import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/dashboard/presentation/screens/budgets_screen.dart';
import 'package:mobile_app_frontend/dashboard/presentation/screens/saving_goals_screen.dart';
import 'package:mobile_app_frontend/expenses/presentation/screens/expense_screens.dart';
import 'package:mobile_app_frontend/dashboard/presentation/screens/dashboard_screens.dart';
import 'package:mobile_app_frontend/shared/presentation/screens/chatbot_alerts_profile.dart';
import 'package:mobile_app_frontend/shared/presentation/screens/home_screen.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  User? _currentUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await AuthDI.userRepository.getCurrentUser();
    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _currentUser = user;
      _pages = [
        HomeScreen(user: user),
        const BudgetsScreen(),
        const SavingsGoalsScreen(),
        ProfileScreen(user: user),
      ];
      _loading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryGreen,
              onPressed: () => _showTransactionMenu(context),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.cardBg,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textSecondary,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Metas de ahorro'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  void _showTransactionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TransactionButton(
              icon: Icons.arrow_upward,
              label: 'Registrar Ingreso',
              color: Colors.green,
              onPressed: () {
                Navigator.pop(context);
                context.push('/home/transaction/income');
              },
            ),
            const SizedBox(height: 12),
            _TransactionButton(
              icon: Icons.arrow_downward,
              label: 'Registrar Gasto',
              color: Colors.red,
              onPressed: () {
                Navigator.pop(context);
                context.push('/home/transaction/expense');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _TransactionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.darkBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
