import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) {
          return Scaffold(
            body: Center(child: Text('App')),
          );
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          return Scaffold(
            body: Center(child: Text('Login')),
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          return Scaffold(
            body: Center(child: Text('Home')),
          );
        },
        routes: [
          GoRoute(
            path: 'dashboard',
            name: 'dashboard',
            builder: (context, state) {
              return Scaffold(
                body: Center(child: Text('Dashboard')),
              );
            },
          ),
          GoRoute(
            path: 'expenses',
            name: 'expenses',
            builder: (context, state) {
              return Scaffold(
                body: Center(child: Text('Expenses')),
              );
            },
          ),
          GoRoute(
            path: 'incomes',
            name: 'incomes',
            builder: (context, state) {
              return Scaffold(
                body: Center(child: Text('Incomes')),
              );
            },
          ),
          GoRoute(
            path: 'budgets',
            name: 'budgets',
            builder: (context, state) {
              return Scaffold(
                body: Center(child: Text('Budgets')),
              );
            },
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) {
              return Scaffold(
                body: Center(child: Text('Profile')),
              );
            },
          ),
          GoRoute(
            path: 'chatbot',
            name: 'chatbot',
            builder: (context, state) {
              return Scaffold(
                body: Center(child: Text('Chatbot')),
              );
            },
          ),
        ],
      ),
    ],
  );
}
