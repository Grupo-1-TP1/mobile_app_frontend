import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/dashboard/presentation/screens/budgets_screen.dart';
import 'package:mobile_app_frontend/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mobile_app_frontend/dashboard/presentation/screens/saving_goals_screen.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/budget_recommendation/budget_recommendation_service_io.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/classifier/expense_classifier_service_io.dart';
import 'package:mobile_app_frontend/shared/presentation/screens/home_screen.dart';
import 'package:mobile_app_frontend/shared/presentation/screens/profile_screen.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';
import 'package:mobile_app_frontend/shared/infrastructure/push_notifications_service.dart';
import 'package:flutter/foundation.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;
  List<Widget> _pages = <Widget>[];
  User? _currentUser;
  bool _loading = true;
  bool _isIaReady = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final user = await AuthDI.userRepository.getCurrentUser();
      if (!mounted) return;

      if (user == null) {
        context.go('/login');
        return;
      }

      setState(() {
        _currentUser = user;
        _pages = [
          HomeScreen(user: user),
          const DashboardReportScreen(),
          const SavingsGoalsScreen(),
          ProfileScreen(),
        ];
        _loading = false;
      });

      try {
        if (!kIsWeb) {
          await PushNotificationsService.instance.subscribeToUserTopic(user.id);
        }
      } catch (error) {
        debugPrint('No se pudo suscribir al tópico: $error');
      }
    } catch (error) {
      debugPrint('Error cargando sesión: $error');
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      context.go('/login');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _pages.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: _pages[_selectedIndex],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Metas de ahorro',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
