import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/user_and_profile/presentation/screens/splash_onboarding_screen.dart';
import 'package:mobile_app_frontend/user_and_profile/presentation/screens/auth_screens.dart';
import 'package:mobile_app_frontend/expenses/presentation/screens/expense_screens.dart';
import 'package:mobile_app_frontend/dashboard/presentation/screens/dashboard_screens.dart';
import 'package:mobile_app_frontend/shared/presentation/screens/chatbot_alerts_profile.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashOnboardingScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardReportScreen(),
          ),
          GoRoute(
            path: 'budgets',
            name: 'budgets',
            builder: (context, state) => const BudgetsScreen(),
          ),
          GoRoute(
            path: 'savings',
            name: 'savings',
            builder: (context, state) => const SavingsGoalsScreen(),
          ),
          GoRoute(
            path: 'transaction/:type',
            name: 'transaction',
            builder: (context, state) {
              final type = state.pathParameters['type'] ?? 'expense';
              return RegisterTransactionScreen(type: type);
            },
          ),
          GoRoute(
            path: 'history',
            name: 'history',
            builder: (context, state) => const TransactionHistoryScreen(),
          ),
          GoRoute(
            path: 'chatbot',
            name: 'chatbot',
            builder: (context, state) => const ChatbotAssistantScreen(),
          ),
          GoRoute(
            path: 'alerts',
            name: 'alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
